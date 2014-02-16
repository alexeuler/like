require "net/http"
require "uri"
require "celluloid"
require "json"
require "timeout"
module Crawler
  module Api
    class Requester
      
      VK_TIMEOUT=30
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
          response={error: {error_msg: "Requester timeout in #{@timeout} seconds"}}
        rescue JSON::ParserError
          response={error: {error_msg: "Unable to parse json from vk"}}
        rescue Exception => e
          response={error: {error_msg: e.message}}
        end
        response[:incoming]=args[:incoming]
        begin
          args[:socket].write response.to_json+"\r\n"
        rescue IOError
          args[:socket].close
        end
      end
    end
  end
end
