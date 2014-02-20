require 'tempfile'

TOKEN_FILENAME=File.expand_path("../crawler/api/tokens/tokens.csv",
                                File.dirname(__FILE__))
CUSHIONS_NUMBER = 10
REQUESTS_NUMBER = 10

def make_tokens(number, temp = nil)
  temp ||= Tempfile.new("tokens")
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

def count_average_time(socket)
  start = Time.now
  REQUESTS_NUMBER.times do
    socket.puts({method: "users.get"}.to_json)
  end
  res = []
  REQUESTS_NUMBER.times do
    response = socket.gets.chomp
    json = JSON.parse response, symbolize_names: true
    json[:error] ? res <<  1 : res << 0
  end
  fail_rate = (res.inject(0) {|sum,x| sum + x}).to_f / REQUESTS_NUMBER
  time = Time.now - start
  average_request_time = time / REQUESTS_NUMBER
  {time: average_request_time *(1 + fail_rate), fail_rate: fail_rate}
end

def cushion_time(socket)
  res=[]
  CUSHIONS_NUMBER.times do |i|
    Celluloid::Actor[:manager].cushion = (CUSHIONS_NUMBER / 2 - i) * 0.025
    res << count_average_time(socket).merge({cushion: Celluloid::Actor[:manager].cushion})
    puts res.last
  end
  res
end

desc "calculates response time for different cushions"
task :cushion do
  require File.expand_path("../crawler/api/server", File.dirname(__FILE__))
  tokens_number = count_tokens
  temp = make_tokens(1)
  server = Crawler::Api::Server.new token_filename: temp.path, retries: 0
  server.async.start
  sleep 0.5
  socket = TCPSocket.new("localhost", 9000)
  cushion_time(socket)
end