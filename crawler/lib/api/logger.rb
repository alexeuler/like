require "logger"
module Api
  module Logger
    def log
      Logger.log
    end

    def self.log
      if @log.nil?
        @log=::Logger.new(File.dirname(__FILE__)+"/daemon_data/daemon.log")
        log.level = ::Logger::INFO
      end
      @log
    end

  end
end
