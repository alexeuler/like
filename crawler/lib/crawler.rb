require_relative "vk_api"
require_relative "models/frontier"
require_relative "fetcher"
class Crawler

  POOL_SIZE=20
  
  def initialize(args={})
    @pool=Fetcher.pool(size: POOL_SIZE, args: [{socket: TCPSocket.new "localhost", 9000}])
  end

  def start
    loop do
      #get_id
      #spawn_fetcher             # blocking request
    end
  end
  
end
