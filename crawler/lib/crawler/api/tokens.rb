require_relative "logging"
require 'json'


module Crawler
  module Api
    class Tokens

      class EmptyTokensFile < RuntimeError
      end

      include Logging

      attr_accessor :source

      def initialize(args={})
        @source=args[:source] || ""
        @data=[]
        @timestamp=Time.now
      end

      def pick
        load if @data.count == 0 or source_modified?
        @data.min_by { |x| x[:last_used] }
      end

      def last_used
        return Time.now - 60*60*24 if @data.count == 0
        token=@data.max_by { |x| x[:last_used] }
        token[:last_used]
      end

      def touch(token)
        token[:last_used]=Time.now
      end

      private

      def load
        @data=[]
        begin
          File.open(source) do |f|
            while line=f.gets
              values=line.chomp.split(";")
              @data << {value: values[0], expires: Time.at(values[1].to_i), id: values[2],
                        last_used: Time.now} if Time.at(values[1].to_i)>Time.now
            end
          end
        rescue Errno::ENOENT
          log.error "File not found: #{source}"
        end
        raise EmptyTokensFile if @data.count == 0
        @timestamp=Time.now
      end

      def source_modified?
        begin
          File::mtime(source) >= @timestamp
        rescue Errno::ENOENT
          log.error "File not found: #{source}"
        end
      end

    end
  end
end
