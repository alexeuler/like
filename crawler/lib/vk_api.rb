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
  end
  
  def method_missing(method, *args, &block)
    success=false
    request=request(method, *args).to_json
    resp=""
    while (not success) and @retries > 0
      begin
        @socket.puts request
        resp=Timeout::timeout(@timeout) {@socket.gets}
        resp["error"] && if resp["error"]["error_msg"]=~/Too many requests/i
          @retries-=1
          continue
        end
      rescue Exception => e
        @retries-=1
      end
    end
    JSON.parse resp
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
