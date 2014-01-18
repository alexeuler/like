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
      socket=args[:socket]
      begin
      while line=Timeout::timeout(CONNECTION_TIMEOUT) {socket.gets}
        line.chomp!
        request=process_request line
        self.class.request_queue.push({socket: socket, request: request, incoming: line})
      end
        self.class.request_queue.push({socket: socket, request: "service", close: true}) #to close the socket after all requests are finished
      ensure
        socket.close
      end
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
