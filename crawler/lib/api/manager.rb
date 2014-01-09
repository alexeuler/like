require "celluloid"
module Api
  class Manager

    include Celluloid

    # Token file structure
    # token_value;expires;vk_id\n
    Token=Struct.new(:value, :expires, :id, :last_access)

    class << self
      attr_accessor :request_queue
    end

    attr_accessor :tokens

    def initialize(args={})
      args=defaults.merge args
      @token_filename=args[:token_filename]
      @server_requests_per_sec=args[:server_requests_per_sec]
      @id_requests_per_sec=args[:id_requests_per_sec]
      @requester=args[:requester]
    end

    def start
      load_tokens
      loop do
        tuple=self.class.request_queue.pop
        token=pick_token
        tuple[:request] << "access_token=#{token.value}"
        now=Time.now
        sleep sleep_time(token, now)
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

    private

    def load_tokens
      @tokens=[]
      File.open(@token_filename, "r") do |f|
        while line=f.gets
          values=line.split(";")
          token=Token.new(values[0],Time.at(values[1].to_i), values[2],Time.now)
          @tokens << token
        end
      end
    end

    def defaults
      {server_requests_per_sec: 10, id_requests_per_sec: 3}
    end

  end
end
