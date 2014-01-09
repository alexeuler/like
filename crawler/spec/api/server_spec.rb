require "socket"
require "json"
require "api/server"
module Api
  describe "Api::Server" do
    it "starts a server on localhost:9000, w8s for json as incoming request and and answers with response from vk" do
      Server.start
      sleep 0.05
      s=TCPSocket.new("localhost", 9000)
      hash={method: "users.get"}
      s.puts hash.to_json
      line=s.gets
      response=JSON.parse line
      response["response"][0]["uid"].to_i.should>0
    end
  end
end
