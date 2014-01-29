#require_relative "../config/activerecord"
require_relative "fetcher"
#require_relative "vk_api"
#require_relative "manager"
class Crawler

  MAX=20
  
  def initialize(args={})
    @fetchers=[]
    MAX.times do
      @fetchers << Fetcher.new(socket: TCPSocket.new("localhost", 9000), manager: Manager.new)
    end
    @fetchers.each { |f| f.async.start }
  end
  
end

#Post.api=UserProfile.api=VkApi.new
#Crawler.new
#sleep
