require_relative "../config/helpers"
require_relative "spider"
path = File.expand_path("models", __dir__)
Helpers.require_dir(path)

module Crawler
  class Bot
    SPIDERS_NUMBER = 2

    def self.start
      spiders = []
      SPIDERS_NUMBER.times do
        spiders << Spider.supervise
      end
      sleep
    end
  end
end

include Crawler
include Crawler::Models
Bot.start