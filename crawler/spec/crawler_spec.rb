require "crawler"
describe Crawler do

  it "prepares a pool of #{Crawler::POOL_SIZE} Fetcher processes" do
    
  end
  
  it "pauses spawning when #{Crawler::POOL_SIZE} fetchers are active" do
    Celluloid.logger = nil
    Fetcher.any_instance.stub(:spawn) do |proc| 
      sleep 1
      proc.call
    end
    TCPSocket.stub(:new)
    crawler=Crawler.new
    continue=true
    Thread.abort_on_exception=true 
    Thread.new do
      while continue do
        pool_size=crawler.instance_variable_get(:@pool_size)
        pool_size.size.should<=Crawler::POOL_SIZE
      end
    end
    crawler.async.start
    sleep 1
    continue=false
    sleep 1.5
  end  
end
