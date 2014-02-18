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

        def stub_http_response(args = {})
          response = args[:response] || {}
          count = args[:count] || Requester::MAX_RETRIES + 1
          Net::HTTP.should_receive(:get_response).exactly(count).times do |uri|
            uri.host.should == "vk.com"
            res=double ("response")
            res.stub(:body).and_return(response.to_json)
            yield if block_given?
            res
          end
        end

        def make_queue(requester)
          queue = double("queue")
          queue.should_receive(:shift).exactly(
              Requester::MAX_RETRIES).times do |tuple|
            requester.async.push(tuple)
          end
          queue
        end

        def make_requester(args = {})
          requester=Requester.new args
          queue=args[:queue] && make_queue(requester)
          requester.async.push(request: "http://vk.com", incoming: "incoming",
                               socket: @socket, queue: queue)
          requester
        end

        it "sends http <request> and writes to <socket>: {response: <response>, incoming: <incoming>}\\r\\n" do
          stub_http_response response: {response: "ok"}, count: 1
          make_requester
          answer=@peer.gets.chomp
          JSON.parse(answer, symbolize_names: true).should == {response: "ok", incoming: "incoming"}
        end

        context "when server doesn't respond" do
          it "retries #{Requester::MAX_RETRIES} times and returns timeout error" do
            stub_http_response { raise Celluloid::Task::TimeoutError }
            timeout = 0.000001
            make_requester(timeout: timeout, queue: true)
            answer=@peer.gets.chomp
            JSON.parse(answer, symbolize_names: true).should ==
                {error: {error_msg: "Requester timeout in #{timeout} seconds"}, incoming: "incoming"}
          end
        end

        context "when server responds not with JSON" do
          it "retries #{Requester::MAX_RETRIES} times and returns JSON error" do
            stub_http_response response: "sdfsdf"
            make_requester queue: true
            answer=@peer.gets.chomp
            JSON.parse(answer, symbolize_names: true).should == {:error=>{:error_msg=>"Unable to parse json from vk"}, incoming: "incoming"}
          end
        end

        context "when server responds with {error: ...}" do
          it "retries #{Requester::MAX_RETRIES} times and returns the error" do
            stub_http_response response: {error: "vk error"}
            make_requester queue: true
            answer=@peer.gets.chomp
            JSON.parse(answer, symbolize_names: true).should == {:error => "vk error", incoming: "incoming"}
          end
        end


      end
      
    end
  end
end
