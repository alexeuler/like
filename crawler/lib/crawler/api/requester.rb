require "net/http"
require "uri"
require "celluloid"
require "json"
require "timeout"
module Crawler
  module Api
    class Requester

      VK_TIMEOUT=30
      MAX_RETRIES = 3
      include Celluloid::IO

      def initialize(args={})
        @timeout=args[:timeout] || VK_TIMEOUT
      end

      def push(args)
        begin
          vk_response=Celluloid.timeout(@timeout) do
            uri=URI.parse(args[:request])
            Net::HTTP.get_response(uri)
          end
          response=JSON.parse vk_response.body, symbolize_name: true
        rescue Celluloid::Task::TimeoutError
          return if do_retry(args)
          response={error: {error_msg: "Requester timeout in #{@timeout} seconds"}}
        rescue JSON::ParserError
          return if do_retry(args)
          response={error: {error_msg: "Unable to parse json from vk"}}
        rescue Exception => e
          return if do_retry(args)
          response={error: {error_msg: e.message}}
        end
        response[:incoming]=args[:incoming]
        begin
          args[:socket].write response.to_json+"\r\n"
        rescue IOError
          log.warn "Requester attempted to write a response, but the socket was closed"
        end
      end

      private

      def do_retry(args)
        args[:request] = /access_token/.match(args[:request]).pre_match
        args[:retries] ||= MAX_RETRIES
        if args[:retries] > 0
          args[:retries]-=1
          tuple[:queue].push args
          Celluloid::Actor[:manager].signal(:pushed, 1) if Celluloid::Actor[:manager]
          return true
        end
        return false
      end

    end
  end
end
