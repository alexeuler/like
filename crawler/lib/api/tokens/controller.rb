require 'erb'
require 'json'
require 'net/http'
require 'uri'
require_relative 'token'

class Controller
  def call(env)
    @tokens=Token.load
    @redirect_uri=ENV['VK_APP_URI']
    @id=ENV['VK_APP_ID']
    @secret=ENV['VK_APP_SECRET']

    request=Rack::Request.new(env)
    if code=request.GET["code"]
      uri=URI.parse "https://api.vk.com/oauth/token?client_id=#{@id}&redirect_uri=#{@redirect_uri}&code=#{code}&client_secret=#{@secret}"
      resp=Net::HTTP.get_response(uri).body
      data=JSON.parse resp
      if token=data["access_token"]
        #save token
      end
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

end
