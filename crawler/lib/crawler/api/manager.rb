require "celluloid"
require_relative "logging"
require_relative "tokens"
module Crawler
  module Api
    class Manager

      include Logging
      include Celluloid

      attr_accessor :cushion

      def initialize(args={})
        args=defaults.merge args
        @tokens=Tokens.new source: args[:token_filename]
        @server_requests_per_sec=args[:server_requests_per_sec]
        @id_requests_per_sec=args[:id_requests_per_sec]
        @queue=args[:queue]
        @requester=args[:requester]
        @cushion = args[:cushion] || 0.025
      end

      def start
        @active=true
        while @active
          begin
            tuple=@queue.pop(true)
          rescue ThreadError
            @active ? Actor.current.wait(:pushed) : next
            retry
          end
          token=@tokens.pick
          tuple[:request] << "access_token=#{token[:value]}"
          tuple[:queue] = @queue
          wait_to_be_polite_to_server(token)
          log.info "Starting request #{tuple[:request]}"
          @requester.async.push tuple
          @tokens.touch(token)
        end
      end


      def shutdown
        @active=false
      end

      private

      def wait_to_be_polite_to_server(token)
        delay=token_sleep_time(token)
        sleep delay + @cushion if delay>0
      end

      def token_sleep_time(token)
        now=Time.now
        delay=[sleep_time(token[:last_used], now, @id_requests_per_sec), sleep_time(@tokens.last_used, now, @server_requests_per_sec)].max
        delay.round(3)
      end

      def sleep_time(last_used, now, frequency)
        [1.0/frequency-now.to_f+last_used.to_f, 0].max
      end

      def defaults
        {server_requests_per_sec: 5, id_requests_per_sec: 3, token_filename: 'tokens.csv'}
      end

    end
  end
end
