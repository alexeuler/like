require "vk_api"
require "socket"
describe "VkApi" do
  before :each do
    @client, @server=Socket.pair(:UNIX, :DGRAM, 0)
    @api=VkApi.new socket:@client, timeout: 0.1, retries: 3
  end
  describe "#request" do
    it "converts method name with params into hash for api server" do
      @api.request("users_get", uid: "2", v: "3").should == {method: "users.get", params: {uid: "2",v:"3"}}
    end
  end
end
