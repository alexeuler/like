require_relative "listener"
require_relative "manager"
require_relative "non_block_queue"
require_relative "scheduler"

module Crawler
  module Api

    def self.autoload
      queue=NonBlockQueue.new
      scheduler_pool=Scheduler.pool queue: queue
      listener=Listener.new(host: "localhost", port: 9000, )
      manager=Manager.new queue: queue
    end
    
  end
end

Crawler::Api::autoload
