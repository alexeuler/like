require "api/manager"
require "tempfile"

module Api
  describe "Api::Manager" do
    it "Reads from request_queue, chooses token, delays to conform frequency and spawns a requester" do
      token_file=Tempfile.new('tokens')
      token_file.puts("qwe;1;1")
      token_file.puts("rty;1;2")
      token_file.close

      Manager::request_queue=Queue.new
      Manager::request_queue.push({socket: "Test", request: "Req1&"})
      Manager::request_queue.push({socket: "Test", request: "Req2&"})
      Manager::request_queue.push({socket: "Test", request: "Req3&"})

      requester=double("requester")
      async=double("async")
      requester.stub(:async).and_return(async)
      async.should_receive(:push).with({socket: "Test", request: "Req1&access_token=qwe"})
      async.should_receive(:push).with({socket: "Test", request: "Req2&access_token=rty"})
      async.should_receive(:push).with({socket: "Test", request: "Req3&access_token=qwe"})

      manager=Manager.new token_filename: token_file.path, requester: requester
      manager.async.start
      sleep 1
      token_file.unlink
    end

    it "calculates sleepeing time with respect to last server request and defined frequency" do
      now=Time.now
      id_freq=3
      serv_freq=10
      tokens=[]
      4.times do |i| 
        tokens << Manager::Token.new(i, now+100, i, now+i.to_f/serv_freq)
      end
      manager=Manager.new(server_requests_per_sec: serv_freq, id_requests_per_sec: id_freq)
      manager.tokens=tokens
      now+=3.0/serv_freq      # now is the time of last request
      manager.sleep_time(tokens[0],now).round(3).should==(1.0/serv_freq).round(3) # here only server delay matters
      manager.sleep_time(tokens[1],now).round(3).should==(1.0/id_freq-2.0/serv_freq).round(3)
      manager.sleep_time(tokens[2],now).round(3).should==(1.0/id_freq-1.0/serv_freq).round(3)
      manager.sleep_time(tokens[3],now).round(3).should==(1.0/id_freq).round(3)
    end

  end
end
