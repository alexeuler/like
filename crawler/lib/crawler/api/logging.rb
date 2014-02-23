require "logger"
module Crawler
  module Api
    module Logging

      #Instance logger returns singleton
      def log
        Logging.log
      end
      
      #Singleton logger
      def self.log
        if @log.nil?
          @log=::Logger.new(File.dirname(__FILE__)+"/log/api.log", 2 , 512_000_000)
          log.level = ::Logger::INFO
        end
        @log
      end

    end
  end
end
