require 'rack'
require File.expand_path("../controller", __FILE__)

builder = Rack::Builder.new do
  use Rack::Auth::Basic do |username, password|
    username == 'admin' && password == ENV['VK_CRAWLER_CONTROL_PANEL_PASS']
  end
  run Controller.new
end

Rack::Handler::Mongrel.run builder, :Port => 9292
