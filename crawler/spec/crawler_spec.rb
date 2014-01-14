require "crawler"
describe Crawler do
  after :each do
    @crawler=Crawler.new
  end
  it "spawns and starts #{Crawler::MAX} supervised Fetchers" do
    fetcher=double("fetcher")
    async=double("async")
    Fetcher.should_receive(:supervise).exactly(Crawler::MAX).times.and_return(fetcher)
    TCPSocket.should_receive(:new).exactly(Crawler::MAX).times
    fetcher.should_receive(:async).exactly(Crawler::MAX).times.and_return(async)
    async.should_receive(:start).exactly(Crawler::MAX).times
  end  
end
