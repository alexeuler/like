require "crawler/api/manager"
require 'socket'
require "tempfile"

module Crawler
  module Api
    describe Manager do
      describe "#start" do
        it "Reads from request_queue, chooses token, delays to conform frequency and spawns a requester" do
          token_file=Tempfile.new('tokens')
          token_file.puts("qwe;#{Time.now.to_i+100};1")
          token_file.puts("rty;#{Time.now.to_i+100};2")
          token_file.close

          queue=Queue.new
          queue.push({socket: "Test", request: "Req1&"})
          queue.push({socket: "Test", request: "Req2&"})
          queue.push({socket: "Test", request: "Req3&"})
          requester=double("requester")
          async=double("async")
          requester.stub(:async).and_return(async)
          async.should_receive(:push).with({socket: "Test", request: "Req1&access_token=qwe", queue: queue})
          async.should_receive(:push).with({socket: "Test", request: "Req2&access_token=rty", queue: queue})
          async.should_receive(:push).with({socket: "Test", request: "Req3&access_token=qwe", queue: queue})

          manager=Manager.new token_filename: token_file.path, requester: requester, queue: queue
          manager.wrapped_object.stub(:wait_to_be_polite_to_server)
          manager.async.start
          sleep 0.05
          token_file.unlink
          manager.async.shutdown
        end
      end

      context "when tokens file is empty" do
        it "responds with error" do
          server, client = Socket.socketpair(:UNIX, :DGRAM, 0)
          queue=Queue.new
          queue.push({socket: server, request: "Req1&", incoming: "incoming"})
          requester=double("requester")
          async=double("async")
          requester.stub(:async).and_return(async)
          async.should_not_receive(:push)
          manager=Manager.new token_filename: nil,
                              requester: requester, queue: queue
          manager.async.start
          response = client.gets.chomp
          response.should == {error: "Tokens file is empty",incoming:"incoming"}.to_json
        end
      end

      describe "#token_sleep_time (private method)" do
        it "calculates sleeping time for a token to be polite to vk server" do
          id_freq=3
          serv_freq=10
          manager=Manager.new(server_requests_per_sec: serv_freq, id_requests_per_sec: id_freq)

          tokens=[]
          now=Time.now
          4.times do |i|
            tokens << {value: i, expires: now+100, id: i, last_used: now+i.to_f/serv_freq}
          end

          manager.instance_variable_set(:@tokens, tokens)
          manager.instance_variable_get(:@tokens).stub(:method_missing) do |method, *args|
            raise "undefined method: #{method}" unless method==:last_used
            tokens[3][:last_used]
          end

          now+=3.0/serv_freq # now is the time of last request
          Time.stub(:now).and_return now
          manager.send(:token_sleep_time, tokens[0]).should==(1.0/serv_freq).round(3) # here only server delay matters
          manager.send(:token_sleep_time, tokens[1]).should==(1.0/id_freq-2.0/serv_freq).round(3)
          manager.send(:token_sleep_time, tokens[2]).should==(1.0/id_freq-1.0/serv_freq).round(3)
          manager.send(:token_sleep_time, tokens[3]).should==(1.0/id_freq).round(3)
        end
      end
    end
  end
end
