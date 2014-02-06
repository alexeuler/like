require "spec_helper"
require "crawler/api/scheduler"
module Crawler
  module Api
    describe Scheduler do

      before (:all) do
        @server=Celluloid::IO::TCPServer.new("localhost", 9001)
      end
      
      before :each do
        @socket=Celluloid::IO::TCPSocket.new("localhost", 9001)
        @peer=@server.accept
        Scheduler.queue=Queue.new
        @scheduler=Scheduler.new
        @scheduler.async.push socket: @peer
      end

      after :each do
        @socket.close unless @socket.closed?
        @peer.close unless @peer.closed?
      end

      describe "#push" do
        it "reads in the infinite loop incoming json from socket and pushes request string into the queue"  do
          payload={method: "users.get", params: {id: 1, v: 5}}.to_json
          @socket.puts payload
          sleep 0.05
          Scheduler.queue.pop(true).should=={socket: @peer, request:"https://api.vk.com/method/users.get?id=1&v=5&", incoming: payload}
        end

        context "when it doesn't receive any message in #{Scheduler::CONNECTION_TIMEOUT} seconds" do
          it "closes the connection", skip_before: true do
            @socket=Celluloid::IO::TCPSocket.new("localhost", 9001)
            @peer=@server.accept
            Scheduler.queue=Queue.new
            @scheduler=Scheduler.new(timeout: 0.1)
            @scheduler.wrapped_object.should_receive(:shutdown)
            @scheduler.async.push(socket: @peer)
            sleep 0.15
          end
        end
        
        context "when invalid json received" do
          before :each do
            @socket.puts "{{1"
            @socket.puts "1"
            @socket.puts "{\"method\":1, \"params\":{{}"
          end
          
          it "responds with error \"Unable to parse request\" " do
            3.times {@socket.gets.chomp.should=={error: "Unable to parse request"}.to_json}
          end
        end

        context "when valid json received" do
          context "when method key is not specified" do
            it "responds with error \"Method is not specified\" " do
              @socket.puts({params:{uid:1}}.to_json)
              @socket.gets.chomp.should=={error: "Method is not specified"}.to_json
            end
          end

          context "when params are not hash" do
            it "responds with error \"Params must be a hash\" " do
              @socket.puts({method: "users.get", params: [1,2]}.to_json)
              @socket.gets.chomp.should=={error: "Params must be a hash"}.to_json
            end
          end
        end
      end
    end
  end
end
