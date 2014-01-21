require "net/http"
require "uri"
require "celluloid"
require "json"
require "timeout"
module Api
  class Requester
    
    VK_TIMEOUT=10
    include Celluloid

    def push(args)
      begin
        vk_response=Timeout::timeout(VK_TIMEOUT) do
          Net::HTTP.get_response(URI.parse(args[:request]))
        end
        response=JSON.parse vk_response.body
      rescue Timeout::Error =>e
        response={error: {error_msg: "Request timeout in #{VK_TIMEOUT} seconds"}}
      rescue JSON::ParserError => e
        response={error: {error_msg: "Unable to parse json from vk"}}
      rescue Exception => e
        response={error: {error_msg: e.message}}
      end
      response[:incoming]=args[:incoming]
      args[:socket].write response.to_json+"\r\n"
    end
  end
end
