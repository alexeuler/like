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
      @socket = args[:socket]
      @timeout = args[:timeout] || DEFAULTS[:timeout]
    end

    def method_missing(method, *args, &block)
      method=method.to_s
      method.gsub!("_",".")
      put(method, args)
      get
    end

    private

    def put(method, args = {})
      request = {method: method, params: args[0]}
      begin
        socket.puts request.to_json
      rescue IOError
        puts "VkApi could not write to socket: #{socket}"
        raise SocketError
      rescue Exception => e
        puts "Unknown exception. VkApi could not write to socket: #{socket}.
          Message: #{e.message}"
        raise SocketError
      end
    end

    def get
      begin
      response = Timeout::timeout(timeout) {socket.gets}
      rescue Timeout::Error
        puts "VkApi connection did not respond in #{timeout} secs"
        raise SocketError
      rescue IOError
        puts "VkApi could not read from socket: #{socket}"
        raise SocketError
      rescue  Exception => e
        puts "Unknown exception reading from socket: #{socket}.
          Message: #{e.message}"
        raise SocketError
      end
      response.chomp!
      begin
        sanitized = response.force_encoding("UTF-8").each_char
        .select{|c| c.bytes.count < 4 }.join('') # remove all special characters
        JSON::parse sanitized, symbolize_names: true
      rescue
        puts "VkApi was unable to parse response: #{response}"
        raise InvalidResponse
      end
    end

  end
end
