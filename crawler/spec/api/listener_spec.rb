require "api/listener"

module Api
  class TestScheduler
    @@pushed=0
    def self.pushed
      @@pushed
    end
    def async
      self
    end
    def push(args={})
      @@pushed+=1
    end

  end


  describe "Api::Listener" do
    it "listens on specified port and spawns scheduler on each connection" do
      scheduler=TestScheduler.new
      listener=Listener.new host: "localhost", port: 9000, scheduler: scheduler
      listener.async.start
      sleep 0.05
      5.times {TCPSocket.new("localhost", 9000)}
      sleep 0.05
      TestScheduler.pushed.should==5
      Celluloid.shutdown
    end
    
  end
end
