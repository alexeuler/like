require_relative "../config/helpers"
require_relative "spider"
path = File.expand_path("models", __dir__)
Helpers.require_dir(path)
include Crawler
include Crawler::Models

module Crawler
  class Bot
    SPIDERS_NUMBER = 3

    def self.start
      spiders = []
      mutex = Mutex.new
      SPIDERS_NUMBER.times do
        spiders << Spider.supervise(mutex: mutex)
      end
      sleep
    end
  end
end

Bot.start