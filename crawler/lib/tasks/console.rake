require_relative '../../lib/crawler/vk_api'
require_relative '../../lib/config/db'
require_relative '../../lib/config/helpers'
Helpers.require_dir(File.expand_path("../crawler/models",
                                     File.dirname(__FILE__)))
require 'socket'

desc "Runs the console with @api and db connection"
task :console do
  require "irb"
  ARGV.clear
  Rake::Task["api:start"].invoke
  retries = 0
  begin
    @socket = TCPSocket.new("localhost", 9000)
  rescue Errno::ECONNREFUSED
    sleep 0.1
    retries+=1
    retry unless retries > 20
  end
  begin
    DB.checkout
    include Crawler::Models
    @api = Crawler::VkApi.new(socket: @socket)
    IRB.start
  ensure
    DB.checkin
  end
end