require "net/http"
require "uri"
require "celluloid"
require "json"
require "timeout"
module Api
  class Requester
    
    VK_TIMEOUT=60
    include Celluloid

    def push(args)
      if args[:close]
        args[:socket].close
      else
        begin
          vk_response=Timeout::timeout(VK_TIMEOUT) do
            Net::HTTP.get_response(URI.parse(args[:request]))
          end
          response=JSON.parse vk_response.body
        rescue Timeout::Error =>e
          response={error: {error_msg: "Request timeout in #{VK_TIMEOUT} seconds"}}
        end
        response[:id]=args[:id]
        args[:socket].write response.to_json+"\r\n"
      end
    end
  end
end
