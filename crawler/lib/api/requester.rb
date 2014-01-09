require "net/http"
require "uri"
require "celluloid"
module Api
  class Requester
    include Celluloid
    def push(args)
      socket=args[:socket]
      uri=URI.parse(args[:request])
      response=Net::HTTP.get_response(uri).body
      socket.puts response
    end
  end
end
