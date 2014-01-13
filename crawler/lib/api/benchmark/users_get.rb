require 'benchmark'
require 'socket'
require 'json'

TIMES=3*20

Benchmark.bm do |x|
  x.report("users.get 18 times") do
    s=TCPSocket.new "localhost", 9000
    requests=(1..TIMES).map {|i| {method: "users.get", params: {uids: i}}.to_json}
    threads=[]
    s=TCPSocket.new "localhost", 9000
    TIMES.times {|i| s.puts requests[i]}
    TIMES.times do
      threads << Thread.new do
        line=s.gets
        res=JSON.parse line
        puts res
      end
    end
    threads.each {|t| t.join}
  end
end

