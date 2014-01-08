require "json"
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
      request_queue.push request
    end

    private

    def process_request(request)
      hash=JSON.parse(request)
      res="https://api.vk.com/method/#{hash.method}?"
      hash.params.each_pair do |key,value|
        res+="#{key}=#{value}&"
      end
      res
    end

  end
end
