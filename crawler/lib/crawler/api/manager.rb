require "celluloid"
require_relative "logging"
module Crawler
  module Api
    class Manager
      include Logging
      include Celluloid

      # Token file structure
      # token_value;expires;vk_id\n
      Token=Struct.new(:value, :expires, :id, :last_access)

      class << self
        attr_accessor :request_queue
      end

      def initialize(args={})
        args=defaults.merge args
        @token_filename=args[:token_filename]
        @server_requests_per_sec=args[:server_requests_per_sec]
        @id_requests_per_sec=args[:id_requests_per_sec]
        @requester=args[:requester]
        @tokens=[]
      end

      def start
        loop do
          tuple=self.class.request_queue.pop
          load_tokens
          token=pick_token
          tuple[:request] << "access_token=#{token.value}"
          now=Time.now
          delay=sleep_time(token, now).round(3)
          sleep delay if delay>0
          log.info "Starting request #{tuple[:request]}"
          @requester.async.push tuple
          token.last_access=Time.now
        end
      end

      def pick_token
        @tokens.min_by(&:last_access)
      end

      def sleep_time(token, now)
        last_server_access=@tokens.max_by(&:last_access).last_access
        last_id_access=token.last_access
        server_delay=[1.0/@server_requests_per_sec-now.to_f+last_server_access.to_f,0].max
        id_delay=[1.0/@id_requests_per_sec-now.to_f+last_id_access.to_f,0].max
        [server_delay, id_delay].max
      end

      def tokens
        @tokens
      end

      def tokens=(value)
        @tokens=value
      end


      private

      def load_tokens
        new_tokens=[]
        File.open(@token_filename, "r") do |f|
          while line=f.gets
            values=line.split(";")
            token=Token.new(values[0],Time.at(values[1].to_i), values[2],Time.now)
            new_tokens << token
          end
        end
        old_values=@tokens.map(&:value)
        new_values=new_tokens.map(&:value)
        @tokens.keep_if {|x| new_values.include?(x.value)}
        @tokens.concat(new_tokens.delete_if {|x| old_values.include? x.value})
      end

      def defaults
        {server_requests_per_sec: 5, id_requests_per_sec: 3}
      end

    end
  end
end