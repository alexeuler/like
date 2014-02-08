module Crawler
  module Api
    class Tokens

      attr_accessor :source

      def initialize(args={})
        raise "Source is not specified" unless args[:source]
        @source=args[:source]
        @data=[]
        @timestamp=Time.now
      end

      def pick
        load if @data.count == 0  or source_modified?
        @data.min_by {|x| x[:last_used] }
      end

      def last_used
        load if @data.count == 0  or source_modified?
        token=@data.max_by {|x| x[:last_used] }
        token[:last_used]
      end
      
      def touch(token)
        token[:last_used]=Time.now
      end
      
      def method_missing(method, *args, &block)
        load if @data.count == 0  or source_modified?
        @data.send(method, *args, &block)
      end

      private

      def load
        @data=[]
        File.open(source) do |f|
          while line=f.gets
            values=line.chomp.split(";")
            @data << {value: values[0], expires: Time.at(values[1].to_i), id: values[2], last_used: Time.now} if Time.at(values[1].to_i)>Time.now
          end
        end
        raise "Source contains no tokens" if @data.count == 0
        @timestamp=Time.now
      end

      def source_modified?
        File::mtime(source) >= @timestamp
      end
      
    end
  end
end
