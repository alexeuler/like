require "fetcher"
describe Fetcher, now: true do
  before :each do
    @manager=double("manager")
    @user=double("user")
    UserProfile.stub(:fetch).and_return(@user)
    Post.stub(:fetch)
  end

  it "starts a new fetcher" do
    @manager.should_receive(:get_work).at_least(:once)
    #@user.should_receive(:fetch_friends)
    #UserProfile.should_receive(:fetch)
    #Post.should_receive(:fetch)
    @fetcher=Fetcher.new manager:@manager
    @fetcher.async.start
    sleep 0.05
  end
end
