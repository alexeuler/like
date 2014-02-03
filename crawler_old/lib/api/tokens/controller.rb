require 'erb'
require 'json'
require 'net/http'
require 'uri'

class Controller

  # This one is a bit messy with no tests
  # Just because it is very simple with trackable results
  # Keep in mind though, that it issues new request for id and invalidates older access tokens, so some requests will inevitably fail when update is performed

  Token=Struct.new(:value, :expires, :id, :last_access)
  FILENAME=File.expand_path("../tokens.csv", __FILE__)

  def call(env)
    @redirect_uri=ENV['VK_APP_URI']
    @id=ENV['VK_APP_ID']
    @secret=ENV['VK_APP_SECRET']
    @tokens=load_tokens
    request=Rack::Request.new(env)
    if code=request.GET["code"]
      token=get_token(code)
      save_token(token)
      response=Rack::Response.new
      response.redirect("/")
      response.finish
    elsif id=request.GET["delete"]
      @tokens.delete_if {|x| x.id==id}
      dump_tokens
      response=Rack::Response.new
      response.redirect("/")
      response.finish
    else
      response=Rack::Response.new(render("index.html.erb"))  
      response.finish
    end
    response
  end  

  def render(template)    
    path = File.expand_path("../views/#{template}", __FILE__)    
    ERB.new(File.read(path)).result(binding)  
  end

  private

  def get_token(code)
    uri=URI.parse "https://api.vk.com/oauth/token?client_id=#{@id}&redirect_uri=#{@redirect_uri}&code=#{code}&client_secret=#{@secret}"
    resp=Net::HTTP.get_response(uri).body
    JSON.parse resp
  end

  # This token arg is hash from vk, not Struct Token 
  def save_token(token)
    value=token["access_token"]
    expires=Time.now.to_i+token["expires"].to_i
    uri=URI.parse "https://api.vk.com/method/users.get?access_token=#{value}"
    resp=Net::HTTP.get_response(uri).body
    hash=JSON.parse resp
    id=hash["response"][0]["uid"].to_s
    @tokens.delete_if {|x| x.id==id}
    @tokens << Token.new(value, expires, id)
    dump_tokens
  end

  def load_tokens
    tokens=[]
    begin
      File.open(FILENAME, "r") do |f|
        while line=f.gets
          values=line.chomp.split(";")
          token=Token.new(values[0],values[1], values[2])
          tokens << token
        end
      end
    rescue Exception => e
      tokens=[]
    end
    tokens
  end
  
  def dump_tokens
    File.open(FILENAME, "w") do |f|
      @tokens.each do |token|
        f.puts [token[0], token[1], token[2]].join(";")
      end
    end
  end

end

