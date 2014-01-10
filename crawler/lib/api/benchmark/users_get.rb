require 'benchmark'
require 'socket'
require 'json'

sockets=[]
20.times do
  s=TCPSocket.new "localhost", 9000
  sockets << s
end

request={method: "users.get"}.to_json

Benchmark.bm do |x|
  x.report("users.get 20 times") do
    threads=[]
    sockets.each do |s|
      threads << Thread.new do
        s.puts request
        line=s.gets
        res=JSON.parse line
        puts res if res["error"]
      end
    end
    threads.each {|t| t.join}
  end
end

