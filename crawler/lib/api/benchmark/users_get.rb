require 'benchmark'
require 'socket'
require 'json'
Benchmark.bm do |x|
  x.report("users.get 20 times") do
    threads=[]
    20.times do
      threads << Thread.new do
        s=TCPSocket.new "localhost", 9000
        hash={method: "users.get"}
        s.puts hash.to_json
        line=s.gets
        res=JSON.parse line
        puts res if res["error"]
      end
      threads.each {|t| t.join}
    end
  end
end
