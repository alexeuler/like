require 'daemons'
require_relative "server"
dir=File.expand_path("../", File.dirname(__FILE__))

Daemons.run_proc('api_daemon', {
    dir_mode: :normal,
    dir: "#{dir}/api/log",
    backtrace: true,
    monitor: true,
    log_output: true
}) do
  puts "#{dir}/api/log"
  server = Crawler::Api::Server.new
  server.async.start
  sleep
end