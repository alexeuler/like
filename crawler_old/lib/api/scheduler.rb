require "json"
require "celluloid"
require_relative "logger"
module Api
  class Scheduler
    
    #JSON protocol : {method: <name>, params: {<param1>: <value1>}}
    CONNECTION_TIMEOUT=360
    
    include Logger

    class << self 
      attr_accessor :request_queue
    end

    include Celluloid
    def push(args={})
      @socket=args[:socket]
      begin
        while line=Timeout::timeout(CONNECTION_TIMEOUT) {@socket.gets}
          line.chomp!
          request=process_request line
          request && self.class.request_queue.push({socket: @socket, request: request, incoming: line})
        end
      ensure
        @socket.close unless @socket.nil?
      end
    end

    private

    def process_request(request)
      begin
        hash=JSON.parse(request)
      rescue JSON::ParserError => e
        send_error("Unable to parse request")
        return
      end
      unless hash["method"]
        send_error("Method is not specified")
        return
      end
      res="https://api.vk.com/method/#{hash["method"]}?"
      if hash["params"]
        if hash["params"].class.name=="Hash"
          hash["params"].each_pair {|key,value| res+="#{key.to_s}=#{value.to_s}&"} if hash["params"]
        else
          send_error("Params must be a hash")
          return
        end
      end
      res
    end

    private

    def send_error(message)
      message={error: message}.to_json
      @socket.puts message
    end
    
  end
end
