require "net/http"
require "json"
require "crawler/api/server"


module Crawler
  module Api

    describe Server do

      def make_tokens
        token_file=Tempfile.new('tokens')
        token_file.puts("qwe;#{Time.now.to_i+100};1")
        token_file.puts("rty;#{Time.now.to_i+100};2")
        token_file.close
        token_file.path
      end

      it "receives requests and returns responses" do
        payload = {test: 123}.to_json
        server=Server.new token_filename: make_tokens
        server.async.start
        sleep 1
        Net::HTTP.stub(:get_response) do
          response = double("response")
          response.stub(:body).and_return(payload)
          response
        end
        socket=TCPSocket.new "localhost", 9000
        socket.puts({method: "users_get"}.to_json)
        response = socket.gets.chomp
        response = JSON.parse response, symbolize_names: true
        response.should == {test: 123, incoming: {method: "users_get"}.to_json}
      end
    end
  end
end

