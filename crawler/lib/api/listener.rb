require 'celluloid'
module Api
  class Listener
    include Celluloid
    def initialize(args={})
      args=defaults.merge args
      @host=args[:host]
      @port=args[:port]
      @scheduler=args[:scheduler]
    end

    def start
      @server=TCPServer.new @host, @port
      loop {@scheduler.async.push socket: @server.accept}
    end

    private
    def defaults
      {host: "localhost", port: 9000}
    end

  end
end
