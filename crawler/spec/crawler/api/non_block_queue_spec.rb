module Crawler
  module Api
    describe NonBlockQueue do
      describe "#pop (non_block, task)" do
        it "does a regular pop and stores task for future use in #push" do
          queue=NonBlockQueue.new
          task=double("task")
          queue.push(1)
          queue.push(2)
          queue.length.should == 2
          queue.pop(true, task).should == 1
          queue.length.should == 1
          queue.instance_variable_get(:@task).should==task
        end
      end

      describe "#push (value)" do
        it "does a regular push and calls #resume on stored task" do
          queue=NonBlockQueue.new
          task=double("task")
          queue.push(1)
          queue.pop(true, task).should == 1
          task.should_receive(:resume)
          queue.push(1)
          queue.pop
        end
      end
    
    end
  end
end
