require 'celluloid/io'
require 'celluloid/autostart'
require_relative "logging"
module Crawler
  module Api
    
    class Listener
      include Celluloid::IO
      include Logging
      finalizer :shutdown
      
      DEFAULTS={host:"localhost", port: "9000"}

      attr_accessor :active
        
      def initialize(args={})
        args=DEFAULTS.merge args
        @host=args[:host]
        @port=args[:port]
        @scheduler=args[:scheduler]
        begin
          @server=TCPServer.new @host, @port
        rescue Exception => e
          log.error "Error starting server. Message: #{e.message}"
        end
        log.info "Started server on #{@host}:#{@port}"
      end

      def start
        return if @active
        @active=true
        while @active
          begin
            client=@server.accept
          rescue Exception => e
            @active && log.error("Error accepting connection. Message: #{e}")
          else
            @active ? @scheduler.async.push(socket: client) : client.close
          end
        end
      end

      def stop
        return unless @active
        @active=false
        socket=TCPSocket.new(@host, @port) # hack to unblock accept
        socket.close
      rescue
        log.error "Failed in stopping listener"
      end

      private
      
      def shutdown
        @active=false
        @server.close if @server
      rescue
        log.warn "Error in shutting down listener"
      end
      
    end
  end
end
