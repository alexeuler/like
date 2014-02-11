require "celluloid"

module Crawler
  module Api
    class ApiQueue
      extend Forwardable
      def_delegators :@queue, :push, :pop
      
      def initialize(args={})
        @queue=args[:queue]
        def @queue.push(*args)
          @task.resume if @task
          super
        end

        def @queue.pop(*args)
          @task=args.pop if args.count == 2
          super
        end

      end
      
    end
  end
end
