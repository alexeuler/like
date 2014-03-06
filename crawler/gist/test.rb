require_relative '../lib/crawler/spider'
require_relative "../lib/config/helpers"
path = File.expand_path("../lib/crawler/models", __dir__)
Helpers.require_dir(path)

include Crawler
include Crawler::Models
spider = Spider.new
#spider.async.start
sleep
