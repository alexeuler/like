require "net/http"
require "uri"
require "celluloid"
module Api
  class Requester
    include Celluloid
    def push(args)
      response=Net::HTTP.get_response(URI.parse(args[:request]))
      socket=args[:socket]
      socket.puts response.body
      socket.close
    end
  end
end
