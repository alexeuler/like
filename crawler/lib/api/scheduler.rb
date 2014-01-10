require "json"
require "celluloid"
require_relative "logger"
module Api
  class Scheduler
    
    #JSON protocol : {method: <name>, params: {<param1>: <value1>}}

    include Logger

    class << self 
      attr_accessor :request_queue
    end

    include Celluloid
    def push(args={})
      socket=args[:socket]
      id=0
      while line=socket.gets
        id+=1
        request=process_request line
        self.class.request_queue.push({socket: socket, request: request, id: id})
      end
        self.class.request_queue.push({socket: socket, request: "service", close: true}) #to close the socket after all requests are finished
    end

    private

    def process_request(request)
      hash=JSON.parse(request)
      res="https://api.vk.com/method/#{hash["method"]}?"
      hash["params"].each_pair {|key,value| res+="#{key}=#{value}&"} if hash["params"]
      res
    end

  end
end
