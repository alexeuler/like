require "api/scheduler"
require "socket"

module Api
  describe "Api::Scheduler" do
    it "reads json from socket and pushes request string into request queue" do
      socket=StringIO.new
      Scheduler.request_queue=Queue.new
      scheduler=Scheduler.new
      scheduler.push socket: socket
      request={method: "users.get", params: {id: 1, v: 5}}
      socket.puts request.to_json
      Scheduler.request_queue.pop.should=="https://api.vk.com/method/users.get?id=1&v=5"
    end



  end
end

