require "crawler/api/requester"
require "ostruct"

module Crawler
  module Api
    describe Requester do

      describe "#initialize (timeout: <timeout>)" do
        it "initializes timer" do
          requester=Requester.new timeout: 10
          requester.instance_variable_get(:@timeout).should == 10
        end
      end
      
      describe "#push(socket: <socket>, request: <request>, incoming: <incoming>, ...)" do
        it "sends http <request> and writes to <socket>: {response: <response>, incoming: <incoming>}\\r\\n" do
          socket, peer = Socket.socketpair(:UNIX, :DGRAM, 0)
          Net::HTTP.should_receive(:get_response) do |uri|
            uri.host.should == "vk.com"
            res=OpenStruct.new
            res.body={response: "ok"}.to_json
            res
          end
          requester=Requester.new
          requester.async.push(request: "http://vk.com", incoming: "incoming", socket: socket)
          answer=peer.gets.chomp
          JSON.parse(answer, symbolize_names: true).should == {response: "ok", incoming: "incoming"}
          socket.close
          peer.close
        end

        context "when server doesn't respond" do
          it "returns timeout error" do
            socket, peer = Socket.socketpair(:UNIX, :DGRAM, 0)
            timeout=0.000001
            requester=Requester.new timeout: timeout
            Net::HTTP.should_receive(:get_response) do |uri|
              raise Celluloid::Task::TimeoutError
            end
            requester.async.push(request: "http://vk.com", incoming: "incoming", socket: socket)
            answer=peer.gets.chomp
            JSON.parse(answer, symbolize_names: true).should == {error: {error_msg: "Requester timeout in #{timeout} seconds"}, incoming: "incoming"}
            socket.close
            peer.close
          end
        end

        context "when server respond not with JSON" do
          it "returns JSON error" do
            socket, peer = Socket.socketpair(:UNIX, :DGRAM, 0)
            Net::HTTP.should_receive(:get_response) do |uri|
              uri.host.should == "vk.com"
              res=OpenStruct.new
              res.body="sdfsdf"
              res
            end
            requester=Requester.new
            requester.async.push(request: "http://vk.com", incoming: "incoming", socket: socket)
            answer=peer.gets.chomp
            JSON.parse(answer, symbolize_names: true).should == {:error=>{:error_msg=>"Unable to parse json from vk"}, incoming: "incoming"}
            socket.close
            peer.close

          end
        end

        
      end
      
    end
  end
end
