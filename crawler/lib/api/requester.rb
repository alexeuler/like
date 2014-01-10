require "net/http"
require "uri"
require "celluloid"
module Api
  class Requester
    include Celluloid
    def push(args)
      if args[:close]
        args[:socket].close
      else
        response=Net::HTTP.get_response(URI.parse(args[:request]))
        args[:socket].write response.body+"\r\n"
      end
    end
  end
end
