require 'celluloid'

class Waiter
  include Celluloid

  def pop
    puts Thread.current
    puts "Waiting"
    wait("pushed")
    puts "Done"
  end
end

class Sender
  include Celluloid

  def initialize(actor)
    @actor = actor
  end

  def push
    puts Thread.current
    @actor.signal("pushed", 1)
  end
end

waiter = Waiter.new
sender = Sender.new waiter
waiter.async.pop
sleep 1
sender.async.push
sleep 2