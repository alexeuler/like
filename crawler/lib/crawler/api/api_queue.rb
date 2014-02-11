require "celluloid"

module Crawler
  module Api
    class ApiQueue < Queue

      #Celluloid use Task class for each method call (which is a fiber in essence)
      #It has methods resume and suspend (equivalent to resume and yield in Fiber)
      #When pop is called from manager, ApiQueue stores current task, i.e. fiber in @task variable
      #If Queue is empty Manager suspends the task
      #When a value is pushed into ApiQueue the task resumes
      
      def push(*args)
        @task.resume if @task
        super
      end

      def pop(*args)
        @task=args.pop if args.count == 2
        super
      end
      
    end
  end
end
