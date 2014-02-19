require 'tempfile'

TOKEN_FILENAME=File.expand_path("../crawler/api/tokens/tokens.csv",
                                File.dirname(__FILE__))

def make_tokens(number)
  temp = Tempfile.new("tokens")
  File.open(TOKEN_FILENAME) do |file|
    File.open(temp, "w") do |temp_file|
      number.times do
        line=file.gets
        temp_file.puts line
      end
    end
  end
  temp
end

def count_tokens
  i=0
  File.open(TOKEN_FILENAME) do |file|
    while line = file.gets
     i+=1
    end
  end
  i
end

desc "calculates response time for different cushions"
task :cushion do
  require File.expand_path("../crawler/api/server", File.dirname(__FILE__))
  tokens_number = count_tokens
  raise "empty tokens file #{TOKEN_FILENAME}" if tokens_number == 0
  temp = make_tokens(tokens_number)
  server = Crawler::Api::Server.new token_filename: temp.path, retries: 0
  server.async.start
  sleep 0.5
  socket = TCPSocket.new("localhost", 9000)
  socket.puts({method: "users.get"}.to_json)
  puts socket.gets
end