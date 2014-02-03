require "config/active_record"
require "frontier"
describe Frontier do
  context "::pull" do
    it "gets the vk_id of the next UserProfile to fetch and marks that profile as busy (status=1)" do
      FactoryGirl.create(:frontier_of_3)
      vk_id=Frontier.pull
      min_id=Frontier.first.id
      vk_id.should == Frontier.first.vk_id
      Frontier.first.status.should==1
      Frontier.find(min_id+1).status.should==0
      Frontier.find(min_id+2).status.should==0
    end

    context "first profile is busy" do
      it "skips that profile and returns the next id" do
        FactoryGirl.create(:frontier_of_3_first_busy)
        vk_id=Frontier.pull
        min_id=Frontier.first.id
        vk_id.should == Frontier.find(min_id+1).vk_id
        Frontier.first.status.should==1
        Frontier.find(min_id+1).status.should==1
        Frontier.find(min_id+2).status.should==0
      end
    end

    context "first profile is busy with timeout" do
      it "sets the first profile as not busy and returns its vk_id" do
        FactoryGirl.create(:frontier_of_3_first_busy_with_timeout)
        vk_id=Frontier.pull
        min_id=Frontier.first.id
        vk_id.should == Frontier.first.vk_id
        Frontier.first.status.should==1
        Frontier.find(min_id+1).status.should==0
        Frontier.find(min_id+2).status.should==0
      end
    end

    context "frontier is empty or busy" do
      it "raises frontier is empty error" do
        expect {Frontier.pull}.to raise_error
      end
    end
  end 
end
