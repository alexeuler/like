require "vk_api"
require "socket"
require "json"
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
    before :each do
      @api.stub(:request).and_return "request"
    end
    context "sends a request to predefined socket and w8s for the reply" do
      context "if server responds with an answer" do
        it "returns answer hash" do
          ans={response: "success"}
          @server.puts ans.to_json
          @api.users_get.should==ans
        end
      end
      context "if server doesn't respond or responds with \"too many requests\" error" do
        it "does #{VkApi::RETRIES} retries then returns nil"
      end
    end
  end
  
end
