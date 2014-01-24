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
          @counter % 2 == 0 ? hash={response: hash[:params][:uid], incoming: line} : hash={error: {error_msg: "tOO many requests per sec"}, incoming: line}
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
      it "doesn't support fully identical requests" do
        
      end
      context "if server responds with valid answers and #get is called" do
        it "returns proper responses array" do
          ans=[]
          3.times do |i| 
            @server.puts({response: "Success#{i}"}.to_json)
          end
          3.times {@api.users_get batch: true}
          @api.get.should==[{response: "Success0"}, {response: "Success1"}, {response: "Success2"}]
        end
      end
      context "if server doesn't respond and #get is called" do
        it "raises error: \"#{VkApi::TIMEOUT_ERR_MESSAGE}\"" do
          3.times {@api.users_get batch: true}
          expect {@api.get}.to raise_error
        end
      end
      context "if VK responds with \"Too many requests\" error and #get is called" do
        it "does #{VkApi::RETRIES} retries then raises error: \"#{VkApi::TIMEOUT_ERR_MESSAGE}\"" do
          3.times {@server.puts({error: {error_msg:"Too many requests per second."}}.to_json)}
          3.times {@api.users_get batch: true}
          expect {@api.get}.to raise_error
        end
      end
      context "if VK fails from time to time" do
        it "returns proper responses array" do
          test=TestServer.new socket: @server
          thread=Thread.new {test.start}
          3.times {|i| @api.users_get uid: i, batch: true}
          @api.get.should==[{response: 0}, {response: 1}, {response: 2}]
          thread.join
        end
      end
    end
    context ":batch parameter is ommited" do
      it "returns proper response hash immediately" do
        ans={response: "success"}
        @server.puts ans.to_json
        @api.users_get.should==ans
      end
    end

    it "sanitizes response from unreadable UTF-8", now: true do
      ans={response: "123\u{1f506}"}
      @server.puts ans.to_json
      @api.users_get[:response].should=="123"
      
    end
    
  end


  
end
