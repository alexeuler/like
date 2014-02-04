require "spec_helper"
require "crawler/api/scheduler"
module Crawler
  module Api
    describe Scheduler do

      before (:all) do
        @server=Celluloid::IO::TCPServer.new("localhost", 9001)
      end
      
      before :each do
        @client_socket=Celluloid::IO::TCPSocket.new("localhost", 9001)
        @server_socket=@server.accept
        @queue=Queue.new
        Scheduler.queue=@queue
        @scheduler=Scheduler.new
        @scheduler.async.push socket: @server_socket
      end

      describe "#push" do
        it "reads in the infinite loop incoming json from socket and pushes request string into the queue" do
          request={method: "users.get", params: {id: 1, v: 5}}
          @client_socket.puts request.to_json
          sleep 0.05
          @queue.pop(true).should=={socket: @server_socket, request:"https://api.vk.com/method/users.get?id=1&v=5&", incoming: request.to_json}
        end

        context "when it doesn't receive any message in #{Scheduler::CONNECTION_TIMEOUT} seconds" do
          before (:each) do
            @scheduler=Scheduler.new(timeout: 0.1)
          end
          it "closes the connection" do
            @scheduler.async.push(socket: @server_socket)
            sleep 0.15
            @scheduler.active.should==false
          end
        end
        
        context "when invalid json received" do
          before :each do
            @client_socket.puts "{{1"
            @client_socket.puts "1"
            @client_socket.puts "{\"method\":1, \"params\":{{}"
          end
          
          it "responds with error \"Unable to parse request\" " do
            @client_socket.gets.chomp.should=={error: "Unable to parse request"}.to_json
            @client_socket.gets.chomp.should=={error: "Unable to parse request"}.to_json
            @client_socket.gets.chomp.should=={error: "Unable to parse request"}.to_json
          end
        end

        context "when valid json received" do
          context "when method key is not specified" do
            before (:each) {@client_socket.puts "{\"params\":{\"uid\":1}}"}
            it "responds with error \"Method is not specified\" " do
              @client_socket.gets.chomp.should=={error: "Method is not specified"}.to_json
            end
          end

          context "when params are not hash" do
            before (:each) {@client_socket.puts({method: "users.get", params: [1,2]}.to_json)}
            it "responds with error \"Params must be a hash\" " do
              @client_socket.gets.chomp.should=={error: "Params must be a hash"}.to_json
            end
          end
          
        end

        
      end
    end
  end
end
