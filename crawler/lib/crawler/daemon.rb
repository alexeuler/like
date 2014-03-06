require 'daemons'
require_relative "bot"
dir=File.expand_path("./", File.dirname(__FILE__))

Daemons.run_proc('bot_daemon', {
    dir_mode: :normal,
    dir: "#{dir}/api/log",
    backtrace: true,
    monitor: true,
    log_output: true
}) do
  Bot.start
end