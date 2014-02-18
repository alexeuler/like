require "crawler/api/requester"

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

        before :each do
          @socket, @peer = Socket.socketpair(:UNIX, :DGRAM, 0)
        end

        after :each do
          @socket.close
          @peer.close
        end

        it "sends http <request> and writes to <socket>: {response: <response>, incoming: <incoming>}\\r\\n" do
          Net::HTTP.should_receive(:get_response) do |uri|
            uri.host.should == "vk.com"
            res=double ("response")
            res.stub(:body).and_return({response: "ok"}.to_json)
            res
          end
          requester=Requester.new
          requester.async.push(request: "http://vk.com", incoming: "incoming", socket: @socket)
          answer=@peer.gets.chomp
          JSON.parse(answer, symbolize_names: true).should == {response: "ok", incoming: "incoming"}
        end

        context "when server doesn't respond" do
          it "retries #{Requester::MAX_RETRIES} times and returns timeout error" do
            timeout=0.000001
            requester=Requester.new timeout: timeout
            Net::HTTP.should_receive(:get_response).exactly(
                Requester::MAX_RETRIES + 1).times do |uri|
              raise Celluloid::Task::TimeoutError
            end
            queue = double("queue")
            queue.should_receive(:shift).exactly(
                Requester::MAX_RETRIES).times do |tuple|
              requester.async.push(tuple)
            end
            requester.async.push(request: "http://vk.com", incoming: "incoming",
                                 socket: @socket, queue: queue)
            answer=@peer.gets.chomp
            JSON.parse(answer, symbolize_names: true).should ==
                {error: {error_msg: "Requester timeout in #{timeout} seconds"}, incoming: "incoming"}
          end
        end

        context "when server responds not with JSON" do
          it "retries #{Requester::MAX_RETRIES} times and returns JSON error" do
            requester=Requester.new
            Net::HTTP.should_receive(:get_response).exactly(
                Requester::MAX_RETRIES + 1).times do |uri|
              uri.host.should == "vk.com"
              res=double("response")
              res.stub(:body).and_return("sdfsdf");
              res
            end
            queue = double("queue")
            queue.should_receive(:shift).exactly(
                Requester::MAX_RETRIES).times do |tuple|
              requester.async.push(tuple)
            end
            requester.async.push(request: "http://vk.com", incoming: "incoming", socket: @socket, queue: queue)
            answer=@peer.gets.chomp
            JSON.parse(answer, symbolize_names: true).should == {:error=>{:error_msg=>"Unable to parse json from vk"}, incoming: "incoming"}
          end
        end

        context "when server responds with {error: ...}" do
          it "retries #{Requester::MAX_RETRIES} times and returns the error" do
            requester=Requester.new
            Net::HTTP.should_receive(:get_response).exactly(
                Requester::MAX_RETRIES + 1).times do |uri|
              uri.host.should == "vk.com"
              res=double("response")
              res.stub(:body).and_return({error: "vk error"}.to_json)
              res
            end
            queue = double("queue")
            queue.should_receive(:shift).exactly(
                Requester::MAX_RETRIES).times do |tuple|
              requester.async.push(tuple)
            end
            requester.async.push(request: "http://vk.com", incoming: "incoming", socket: @socket, queue: queue)
            answer=@peer.gets.chomp
            JSON.parse(answer, symbolize_names: true).should == {:error => "vk error", incoming: "incoming"}
          end
        end


      end
      
    end
  end
end
