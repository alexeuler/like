require "vk_api"
require "socket"
require "json"
require "timeout"

class TestServer
  def initialize(args={})
    @socket=args[:socket]
    @counter=0
  end

  def start
    continue=true
    while continue do
      begin
        Timeout::timeout(1) do
          line=@socket.gets
          line.chomp!
          hash=JSON.parse line, symbolize_names: true
          @counter % 2 == 0 ? hash={response: hash[:params][:uid], incoming: line} : hash={error: hash[:params][:uid], incoming: line}
          @socket.puts hash.to_json 
          @counter+=1
        end
      rescue Exception => e
        continue=false
      end
    end
  end
end


describe "VkApi" do
  before :each do
    @client, @server=Socket.pair(:UNIX, :DGRAM, 0)
    @api=VkApi.new socket:@client, timeout: 0.1, retries: 3
  end
  after :each do
    @client.close
    @server.close
  end
  describe "#request" do
    it "converts method name with params into hash for api server" do
      @api.request("users_get", uid: "2", v: "3").should == {method: "users.get", params: {uid: "2",v:"3"}}
    end
  end

  describe "#method_missing" do
    context ":batch parameter set to true" do
      context "sends 3 requests to predefined socket and w8s for the reply" do
        context "if server responds with valid answers" do
          it "returns answer hash" do
            ans=[]
            3.times do |i| 
              @server.puts({response: "Success#{i}"}.to_json)
            end
            3.times {@api.users_get batch: true}
            @api.get.should==[{response: "Success0"}, {response: "Success1"}, {response: "Success2"}]
          end
        end
        context "if server doesn't respond" do
          it "does #{VkApi::RETRIES} retries then raises exception" do
            3.times {@api.users_get batch: true}
            expect {@api.get}.to raise_error
          end
        end
        context "if server responds with \"Too many requests error\"" do
          it "does #{VkApi::RETRIES} retries then returns nil" do
            3.times {@server.puts({error: {error_msg:"Too many requests per second."}}.to_json)}
            3.times {@api.users_get batch: true}
            expect {@api.get}.to raise_error
          end
        end
        context "in environment with mixed responses" do
          it "also behaves correctly", now: true do
            test=TestServer.new socket: @server
            thread=Thread.new {test.start}
            3.times {|i| @api.users_get uid: i, batch: true}
            @api.get.should==[{response: 0}, {response: 1}, {response: 2}]
            thread.join
          end
        end
      end
    end
  end

  context ":batch parameter is ommited" do
    it "sends a request to predefined socket and returns a reply hash" do
      ans={response: "success"}
      @server.puts ans.to_json
      @api.users_get.should==ans
    end
  end
  
end
