require "user_profile"
require "config/active_record"
describe UserProfile do
  context "::fetch" do
    it "fecthes user profiles from vk specified by uids parameter" do
      api=double("api")
      api.should_receive(:users_get).with({uids: "1,2,3", fields: UserProfile::FIELDS}).and_return("test")
      UserProfile.should_receive(:fetch_from_api_response).with("test")
      UserProfile.fetch(uids: [1,2,3], api: api)
    end
  end
end
