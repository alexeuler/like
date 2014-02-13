require "celluloid"

module Crawler
  module Api
    class NonBlockQueue < Queue

      #Celluloid use Task class for each method call (which is a fiber in essence)
      #It has methods resume and suspend (equivalent to resume and yield in Fiber)
      #When pop is called from manager, ApiQueue stores current task, i.e. fiber in @task variable
      #If Queue is empty Manager suspends the task
      #When a value is pushed into ApiQueue the task resumes
      
      def push(*args)
        debugger
        @task && @task.running? && @task.resume 
        super
      end

      def pop(non_block=false, task=nil)
        @task=task if task
        super(non_block)
      end
      
    end
  end
end
