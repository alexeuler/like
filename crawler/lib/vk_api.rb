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
    if args[0]
      batch=args[0][:batch]
      args[0].delete_if { |key, value| key==:batch }
    end
    req=request(method, *args).to_json
    @requests << {data: req, retries: @retries, id: @requests.count}
    @socket.puts req
    get unless batch
  end

  def retry_request
    debugger
    req=@requests.shift
    req[:retries]-=1
    if req[:retries]>0 
      @requests << req
      @socket.puts req[:data]
      true
    else
      @requests.unshift req
      false
    end
  end

  def get
    result=[]
    while @requests.count>0
      resp=""
      begin
        debugger
        resp=Timeout::timeout(@timeout) {@socket.gets}
        resp=JSON.parse resp, :symbolize_names => true
        resp[:error] && if resp[:error][:error_msg]=~/Too many requests/i
                           next if retry_request
                           result << {data: nil, id: @requests.shift[:id]}
                         end
        result << {data: resp, id: @requests.shift[:id]}
      rescue Exception => e
        puts e.message
        next if retry_request
        result << {data: nil, id: @requests.shift[:id]}
      end
    end
    result.sort! {|a,b| a[:id] <=> b[:id] }
    result.map! { |r| r[:data] }
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
