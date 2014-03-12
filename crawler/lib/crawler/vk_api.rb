require 'json'
require 'timeout'
module Crawler
  class VkApi

    class InvalidResponse < RuntimeError
    end
    class SocketError < RuntimeError
    end

    DEFAULTS = {
        timeout: 60
    }

    attr_accessor :socket, :timeout

    def initialize(args={})
      @socket = args[:socket] || TCPSocket.new("localhost", 9000)
      @timeout = args[:timeout] || DEFAULTS[:timeout]
      Thread.current[:api] = self
    end

    def close
      @socket.close
    end

    def method_missing(method, *args, &block)
      method=method.to_s
      method.gsub!("_", ".")
      put(method, args)
      get
    end

    private

    def put(method, args = nil)
      request = {method: method}
      request.merge!({params: args[0]}) if args
      begin
        socket.puts request.to_json
      rescue IOError
        raise SocketError, "VkApi could not write to socket: #{socket}"
      rescue Exception => e
        raise SocketError, "Unknown exception. VkApi could not write to socket: #{socket}.
          Message: #{e.message}"
      end
    end

    def get
      begin
        response = Timeout::timeout(timeout) { socket.gets }
      rescue Timeout::Error
        raise SocketError, "VkApi connection did not respond in #{timeout} secs"
      rescue IOError
        raise SocketError, "VkApi could not read from socket: #{socket}"
      rescue Exception => e
        raise SocketError, "Unknown exception reading from socket: #{socket}.
          Message: #{e.message}"
      end
      response.chomp!
      begin
        sanitized = response.force_encoding("UTF-8").each_char
        .select { |c| c.bytes.count < 4 }.join('') # remove all special characters
        result = JSON::parse sanitized, symbolize_names: true
        result[:response] || result #if error return the whole result
      rescue
        raise InvalidResponse, "VkApi was unable to parse response: #{response}"
      end
    end

  end
end
