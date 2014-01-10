require "net/http"
require "uri"
require "celluloid"
require "json"
module Api
  class Requester
    include Celluloid
    def push(args)
      if args[:close]
        args[:socket].close
      else
        vk_response=Net::HTTP.get_response(URI.parse(args[:request]))
        response=JSON.parse vk_response.body
        response[:id]=args[:id]
        args[:socket].write response.to_json+"\r\n"
      end
    end
  end
end
