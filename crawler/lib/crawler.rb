require_relative "fetcher"
class Crawler

  MAX=20
  
  def initialize(args={})
    @fetchers=[]
    MAX.times do
      @fetchers << Fetcher.supervise(socket: TCPSocket.new("localhost", 9000))
    end
    @fetchers.each { |f| f.async.start }
  end
  
end
