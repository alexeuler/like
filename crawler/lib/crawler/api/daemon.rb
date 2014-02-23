require 'daemons'
require_relative "server"
Daemons.run_proc('api_daemon', {
    dir_mode: :script,
    dir: 'log',
    backtrace: true,
    monitor: true,
    log_output: true
}) do
  server = Crawler::Api::Server.new
  server.async.start
  sleep
end