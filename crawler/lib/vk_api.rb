require "json"
require "timeout"
class VkApi

  TIMEOUT=30
  RETRIES=3

  def initialize(args={})
    args=defaults.merge args
    @socket=args[:socket]
    @timeout=args[:timeout]
    @retries=args[:retries]
    @requests=[]
  end
  
  def method_missing(method, *args, &block)
    req=request(method, *args).to_json
    @requests << {data: req, retries: @retries}
    @socket.puts req
    get_all_responses
  end

  def retry_request
    request=@requests.shift
    request[:retries]-=1
    @requests << request
    @socket.puts request[:data]
    request[:retries]>0
  end

  def get_all_responses
    result=[]
    while @requests.count>0
      resp=""
      begin
        puts @requests.count
        resp=Timeout::timeout(@timeout) {@socket.gets}
        resp=JSON.parse resp, :symbolize_names => true
        resp["error"] && if resp["error"]["error_msg"]=~/Too many requests/i
                           continue if retry_request
                           result << nil
                         end
        @requests.shift
        result << resp
      rescue Exception => e
        continue if retry_request
        result << nil
      end
    end
    result.count==1 ? result[0] : result
  end
  
  def request(method, *args)
    method=method.to_s
    method.gsub!("_",".")
    {method: method, params: args[0]}
  end

  private

  def defaults
    {timeout:TIMEOUT, retires: RETRIES}
  end
end
