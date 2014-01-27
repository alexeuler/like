require "config/active_record"
require "manager"
describe Manager do
  before :each do
    @manager=Manager.new
  end
  context "#get_work" do
    it "gets the vk_id from Frontier" do
      Frontier.stub(:pull).and_return("123")
      @manager.get_work.should=="123"
    end

    context "crawler work is complete" do
      it "throws :done" do
        @manager.stub(:stop?).and_return(true)
        expect {@manager.get_work}.to throw_symbol(:done)
      end
    end
  end

  context "#stop?" do
    it "checks if crawler work is complete. The rule is #{Manager::MAX_POSTS} posts fetched" do
      Post.stub(:count).and_return(Manager::MAX_POSTS)
      @manager.stop?.should==true
      Post.stub(:count).and_return(Manager::MAX_POSTS-1)
      @manager.stop?.should==false
    end
  end

  context "#done" do
    it "deletes vk_id from Frontier" do
      FactoryGirl.create(:frontier)
      Frontier.count.should == 1
      @manager.done(Frontier.first.vk_id)
      Frontier.count.should == 0
    end
  end
  
end
