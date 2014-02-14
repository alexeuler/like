require_relative "listener"
require_relative "manager"
require_relative "scheduler"
require_relative "requester"

module Crawler
  module Api
    class Server
      include Celluloid
      def initialize(args={})
        @token_filename=args[:token_filename] || File.join(File.dirname(__FILE__), "tokens.csv")
      end

      def start
        queue=Queue.new
        scheduler_pool=Scheduler.pool size: 50, args: [{queue: queue}]
        requester_pool=Requester.pool size: 50
        @listener=Listener.new(host: "localhost", port: 9000, scheduler: scheduler_pool)
        @manager=Manager.new queue: queue, requester: requester_pool, token_filename: @token_filename
        Actor[:manager] = @manager
        @manager.async.start
        @listener.async.start
      end
      
    end
  end
end
