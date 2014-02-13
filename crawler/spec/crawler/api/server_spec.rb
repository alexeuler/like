require "net/http"
require "json"
require "crawler/api/server"


module Crawler
  module Api
    
    describe Server, focus: true do

      def make_tokens
        token_file=Tempfile.new('tokens')
        token_file.puts("qwe;#{Time.now.to_i+100};1")
        token_file.puts("rty;#{Time.now.to_i+100};2")
        token_file.close
        token_file.path
      end
      
      it "receives requests and returns responses" do
        server=Server.new token_filename: make_tokens
        server.async.start
        sleep 1
        Net::HTTP.stub(:get_response) do
          resp=Net::HTTPResponse.new(1.0, 200, "OK")
          resp.body="Hello world!"
          resp
        end
        socket=TCPSocket.new "localhost", 9000
        socket.puts({method: "users_get"}.to_json)
        puts socket.gets
      end
    end
  end
end

