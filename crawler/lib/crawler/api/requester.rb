require "net/http"
require "uri"
require "celluloid/io"
require "json"
require "timeout"
require_relative "logging"

module Crawler
  module Api
    class Requester

      VK_TIMEOUT=30
      MAX_RETRIES = 3
      include Celluloid::IO
      include Logging

      def initialize(args={})
        @timeout=args[:timeout] || VK_TIMEOUT
        @retries = args[:retries] || MAX_RETRIES
      end

      def push(args)
        begin
          vk_response=Celluloid.timeout(@timeout) do
            uri=URI.parse(args[:request])
            Net::HTTP.get_response(uri)
          end
          response=JSON.parse vk_response.body, symbolize_names: true
        rescue Celluloid::Task::TimeoutError
          response={error: {error_msg: "Requester timeout in #{@timeout} seconds"}}
        rescue JSON::ParserError
          response={error: {error_msg: "Unable to parse json from vk"}}
        rescue Exception => e
          response={error: {error_msg: e.message}}
        end
        response[:error] && do_retry(args) && return
        response[:incoming]=args[:incoming]
        begin
          args[:socket].write response.to_json+"\r\n"
        rescue IOError
          log.warn "Requester attempted to write a response, but the socket was closed"
        end
      end

      private

      def do_retry(args)
        regex = /access_token/.match(args[:request])
        regex && args[:request] = regex.pre_match
        args[:retries] ||= @retries
        if args[:retries] > 0
          args[:retries]-=1
          args[:queue].shift args
          Celluloid::Actor[:manager].signal(:pushed, 1) if Celluloid::Actor[:manager]
          return true
        end
        false
      end

    end
  end
end
