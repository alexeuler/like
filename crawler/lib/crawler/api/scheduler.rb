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
      
      class << self 
        attr_accessor :queue
      end

      attr_accessor :timeout, :active
      
      def initialize(args={})
        @timeout=args[:timeout] || CONNECTION_TIMEOUT
      end
      
      def push(args={})
        @socket=args[:socket]
        begin
          while incoming=Celluloid.timeout(@timeout) {@socket.gets}
            incoming.chomp!
            request=parse_incoming incoming
            request && self.class.queue.push({socket: @socket, request: request, incoming: incoming})
          end
        rescue Celluloid::Task::TimeoutError
          log.warn "Timeout in scheduler"
        rescue IOError
          #shutdown was called
        ensure
          shutdown
        end
      end

      def shutdown
        @socket.close unless @socket.closed?
      end

      
      private

      def parse_incoming(request)
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
        
        res="https://api.vk.com/method/#{hash["method"].to_s}?"
        return res unless hash["params"]
        
        if hash["params"].class.name=="Hash"
          hash["params"].each_pair {|key,value| res+="#{key.to_s}=#{value.to_s}&"}
        else
          send_error("Params must be a hash")
          return
        end
        
        res
      end
      
      
      def send_error(message)
        message={error: message}.to_json
        @socket.puts message
      end

    end
  end
end
