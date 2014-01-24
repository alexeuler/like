require "json"
require "timeout"
class VkApi

  #Batch doesn't support fully identical requests
  
  TIMEOUT=30
  RETRIES=3
  TIMEOUT_ERR_MESSAGE="Could not complete request in #{RETRIES} times"

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
    @requests << {data: req, retries: @retries}
    @socket.puts req
    get unless batch
  end

  def retry_request(resp)
    req=@requests.select {|x| x[:data]==resp[:incoming]}.first
    req[:retries]-=1
    if req[:retries]>=0
      @socket.puts resp[:incoming]
    else
      raise TIMEOUT_ERR_MESSAGE
    end
  end

  #requests is like [data: json like {method: users.get}, retries:3]
  #resonses from socket (result variable in #get) is like {hash_from_vk, incoming: requests[:data] 

  def get
    raise "VkApi: no requests is sent and #get is called" if @requests.count == 0
    result=[]
    while @requests.count>result.count
      resp=Timeout::timeout(@timeout) {@socket.gets}
      resp=resp.force_encoding("UTF-8").each_char.select{|c| c.bytes.count < 4 }.join('') # remove all special characters
      resp=JSON.parse resp, :symbolize_names => true
      resp[:error] && if resp[:error][:error_msg]=~/Too many requests/i
                        retry_request(resp)
                        next
                      end
      result << resp
    end
    result.sort! do |a,b|
      a_elem=@requests.select {|x| x[:data]==a[:incoming]}.first
      b_elem=@requests.select {|x| x[:data]==b[:incoming]}.first
      @requests.find_index(a_elem) <=> @requests.index(b_elem)
    end
    result.each {|x| x.delete :incoming}
    @requests=[]
    result.count==1 ? result[0] : result
  end
  
  def request(method, *args)
    method=method.to_s
    method.gsub!("_",".")
    {method: method, params: args[0]}
  end

  private

  def defaults
    {timeout:TIMEOUT, retries: RETRIES}
  end
end
