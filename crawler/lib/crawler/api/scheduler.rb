require "json"
require "celluloid/io"
require_relative "logging"
module Crawler
  module Api
    class Scheduler
      
      #JSON protocol : {method: <name>, params: {<param1>: <value1>}}\n
      CONNECTION_TIMEOUT=600
      include Celluloid::IO
      include Logging
      finalizer :shutdown
      
      class << self 
        attr_accessor :queue
      end

      attr_accessor :timeout, :active
      
      def initialize(args={})
        @timeout=args[:timeout] || CONNECTION_TIMEOUT
      end
      
      def push(args={})
        @socket=args[:socket]
        @active=true
        timer=after(@timeout) do
          @active=false
          shutdown
        end
        while @active && incoming=@socket.gets
          incoming.chomp!
          request=make_request incoming
          request && self.class.queue.push({socket: @socket, request: request, incoming: incoming})
          timer.reset
        end
      end

      private

      def make_request(request)
        begin
          hash=JSON.parse(request)
        rescue JSON::ParserError => e
          send_error("Unable to parse request")
          return
        end
        unless hash["method"]
          send_error("Method is not specified")
          return
        end
        res="https://api.vk.com/method/#{hash["method"]}?"
        if hash["params"]
          if hash["params"].class.name=="Hash"
            hash["params"].each_pair {|key,value| res+="#{key.to_s}=#{value.to_s}&"} if hash["params"]
          else
            send_error("Params must be a hash")
            return
          end
        end
        res
      end

      private

      def send_error(message)
        message={error: message}.to_json
        @socket.puts message
      end

      def shutdown
        @socket.close unless @socket.nil?
      rescue
      end
    end
  end
end
