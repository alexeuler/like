require "json"
class VkApi
  def initialize(args={})
    @socket=args[:socket]
  end
  
  def method_missing(method, *args, &block)
    method=method.to_s
    method.gsub!("_",".")
    req={method: method, params: args[0]}
    @socket.puts req.to_json
    resp=@socket.gets
    JSON.parse resp
  end  
end
