require 'benchmark'
require 'socket'
require 'json'

s=TCPSocket.new "localhost", 9000
requests=(1..18).map {|i| {method: "users.get", params: {uids: i}}.to_json}

Benchmark.bm do |x|
  x.report("users.get 18 times") do
    threads=[]
    s=TCPSocket.new "localhost", 9000
    18.times {|i| s.puts requests[i]}
    18.times do
      threads << Thread.new do
        line=s.gets
        res=JSON.parse line
        puts res
        puts res if res["error"]
      end
    end
    threads.each {|t| t.join}
  end
end

