require 'daemons'
require_relative 'server'

Daemons.run_proc('vk_api_daemon', {
              dir_mode: :script,
              dir: 'daemon_data',
              backtrace: true,
              monitor: true,
              log_output: true
                 }) do
  Api::Server.start
  sleep
end
