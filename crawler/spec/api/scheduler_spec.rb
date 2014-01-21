require "api/scheduler"
module Api
  describe "Api::Scheduler" do

    before :each do
      @client, @server=Socket.pair(:UNIX, :DGRAM, 0)
      Scheduler.request_queue=Queue.new
      @scheduler=Scheduler.new
    end
    
    it "reads json from socket and pushes request string into request queue" do
      @scheduler.async.push socket: @server
      request={method: "users.get", params: {id: 1, v: 5}}
      @client.puts request.to_json
      sleep 0.05
      Scheduler.request_queue.pop(true).should=={socket: @server, request:"https://api.vk.com/method/users.get?id=1&v=5&", incoming: request.to_json}
    end 
  end
end

