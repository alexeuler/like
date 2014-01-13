require "json"
class VkApi
  def method_missing(method, *args, &block)
    method=method.to_s
    method.gsub!("_",".")
    res={method: method, params: args[0]}
    res.to_json
  end  
end
