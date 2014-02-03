require "api/scheduler"
module Api
  describe Scheduler do

    before :each do
      @client, @server=Socket.pair(:UNIX, :DGRAM, 0)
      Scheduler.request_queue=Queue.new
      @scheduler=Scheduler.new
      @scheduler.async.push socket: @server
    end
    
    it "reads json from socket and pushes request string into request queue" do
      request={method: "users.get", params: {id: 1, v: 5}}
      @client.puts request.to_json
      sleep 0.05
      Scheduler.request_queue.pop(true).should=={socket: @server, request:"https://api.vk.com/method/users.get?id=1&v=5&", incoming: request.to_json}
    end

    context "receives invalid json" do
      it "responds with error \"Unable to parse request\" " do
        @client.puts "{{1"
        @client.gets.chomp.should=={error: "Unable to parse request"}.to_json
        @client.puts "1"
        @client.gets.chomp.should=={error: "Unable to parse request"}.to_json
        @client.puts "{\"method\":1, \"params\":{{}"
        @client.gets.chomp.should=={error: "Unable to parse request"}.to_json
      end
    end

    context "receives valid json" do
      context "method is not specified" do
        it "responds with error \"Method is not specified\" " do
          @client.puts "{\"params\":{\"uid\":1}}"
          @client.gets.chomp.should=={error: "Method is not specified"}.to_json
        end
      end

      context "params are not hash" do
        it "responds with error \"Params must be a hash\" " do
          @client.puts({method: "users.get", params: [1,2]}.to_json)
          @client.gets.chomp.should=={error: "Params must be a hash"}.to_json
        end
      end
      
    end

    
  end
end

