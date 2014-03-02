require_relative '../lib/crawler/api/server'
require 'json'

server = Crawler::Api::Server.new
server.start
sleep 0.1
socket = TCPSocket.new "localhost", 9000
socket.puts({method: "users.get", params: {uids:[1,2]}}.to_json)
response = socket.gets
puts response