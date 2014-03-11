require_relative "../config/helpers"
require_relative "spider"
path = File.expand_path("models", __dir__)
Helpers.require_dir(path)
include Crawler
include Crawler::Models

module Crawler
  class Bot
    SPIDERS_NUMBER = 5
    def self.start
      spiders = []
      SPIDERS_NUMBER.times do |i|
        spiders << Spider.supervise({number:i})
      end
      sleep
    end
  end
end
