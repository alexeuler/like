require_relative "vk_api"
require_relative "fetcher"
require "celluloid"
class Crawler

  #This class stores the number of active processes
  class PoolSize
    include Celluloid
    attr_accessor :size
    def initialize(args={})
      @size=0
      @mutex=Mutex.new
    end
    
    def up
      @mutex.synchronize do
        @size+=1
      end
    end

    def down
      @mutex.synchronize do
        @size-=1
      end
    end
  end

  POOL_SIZE=20
  include Celluloid
  def initialize(args={})
    @pool_size=PoolSize.new
    begin
      @pool=Fetcher.pool(size: POOL_SIZE, args: [{socket: TCPSocket.new("localhost", 9000)}])
    rescue Exception=>e
      puts "Exception #{e.message}"
    end
    @condition = Celluloid::Condition.new
    @callback=lambda do
      @pool_size.async.down
      @condition.signal
    end 
  end

  def start
    loop do
      @pool_size.async.up
      @pool.async.spawn(@callback)
      @condition.wait if @pool_size.size>=POOL_SIZE
    end
  end
  
end
