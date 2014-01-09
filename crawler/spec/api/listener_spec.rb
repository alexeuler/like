require "api/listener"

module Api

  describe "Api::Listener" do
    it "listens on specified port and spawns scheduler on each connection" do
      scheduler=double
      async=double
      scheduler.stub(:async).and_return(async)
      async.should_receive(:push).exactly(5).times
      listener=Listener.new host: "localhost", port: 9000, scheduler: scheduler
      listener.async.start
      sleep 0.05
      5.times {TCPSocket.new("localhost", 9000)}
      sleep 0.05
    end
    
  end
end
