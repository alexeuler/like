require "vk_api"
describe "VkApi" do
  it "converts method name with params into hash for api server" do
    api=VkApi.new
    api.users_get(uid: "2", v: "3").should == '{"method":"users.get","params":{"uid":"2","v":"3"}}'
  end
end
