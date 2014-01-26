require "config/active_record"
require "manager"
describe Manager, now: true do
  before :each do
    @manager=Manager.new
  end
  context "#get_work" do
    
  end

  context "#stop?" do
    it "checks if specified work is complete. The rule is #{Manager::MAX_POSTS} posts fetched" do
      Post.stub(:count).and_return(Manager::MAX_POSTS)
      @manager.stop?.should==true
      Post.stub(:count).and_return(Manager::MAX_POSTS-1)
      @manager.stop?.should==false
    end
  end
end
