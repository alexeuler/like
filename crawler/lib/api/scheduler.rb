require "json"
require "celluloid"
module Api
  class Scheduler

    #JSON protocol : {method: <name>, params: {<param1>: <value1>}}

    class << self 
      attr_accessor :request_queue
    end

    include Celluloid
    def push(args={})
      socket=args[:socket]
      request=process_request socket.gets
      self.class.request_queue.push({socket: socket, request: request})
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
