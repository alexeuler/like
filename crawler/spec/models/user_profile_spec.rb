require "user_profile"
require "config/active_record"

RESPONSE={response:
  [{:uid=>20,
     :first_name=>"Sergey",
     :last_name=>"Zolin",
     :sex=>2,
     :nickname=>"",
     :screen_name=>"zolin_sergey",
     :bdate=>"28.2.1987",
     :city=>"1",
     :country=>"1",
     :timezone=>3,
     :photo=>"http://cs315126.vk.me/u20/e_sa5c7sdfb1.jpg",
     :photo_medium=>"http://cs315126.vk.me/u20/ad_9f71ce4.jpg",
     :photo_big=>"http://cs315126.vk.me/u20/va_71v48ea.jpg",
     :has_mobile=>1,
     :online=>1,
     :counters=>
     {:albums=>2,
       :videos=>14,
       :audios=>44,
       :notes=>0,
       :photos=>17,
       :groups=>31,
       :friends=>83,
       :online_friends=>10,
       :user_videos=>0,
       :followers=>6},
     :university=>2,
     :university_name=>"LLC",
     :faculty=>23,
     :faculty_name=>"MMA",
     :graduation=>2009,
     :education_form=>"Day",
     :education_status=>"Graduate"}]
}

PROFILE={
  vk_id: 20, 
  first_name:"Sergey",
  last_name:"Zolin",
  photo:"http://cs315126.vk.me/u20/e_sa5c7sdfb1.jpg",
  sex: 2,
  birthday: Date.new(1987, 2, 28),
  university: 2, 
  faculty: 23, 
  city: 1,  
  country: 1, 
  has_mobile: 1, 
  albums_count: 2,
  videos_count: 14,
  audios_count: 44,
  notes_count: 0,
  photos_count: 17,
  groups_count: 31,
  friends_count: 83,
  online_friends_count: 10,
  user_videos_count: 0,
  followers_count: 6
}


describe UserProfile do
  context "::fetch" do
    before :each do
      @api=double("api")
    end
    
    it "fecthes user profiles from vk specified by uids parameter" do
      @api.should_receive(:users_get).with({uids: "1,2,3", fields: UserProfile::FIELDS}).and_return("test")
      UserProfile.should_receive(:fetch_from_api_response).with("test")
      UserProfile.fetch(uids: [1,2,3], api: @api)
    end

    context "uids count > #{UserProfile::MAX_UIDS_PER_REQUEST}" do
      it "splits requests into chunks of size #{UserProfile::MAX_UIDS_PER_REQUEST} then concatenates results", now: true do
        uids=(1..UserProfile::MAX_UIDS_PER_REQUEST+10).to_a
        @api.should_receive(:users_get).with({uids: (1..UserProfile::MAX_UIDS_PER_REQUEST).to_a.join(","), fields: UserProfile::FIELDS}).and_return([1,2])
        @api.should_receive(:users_get).with({uids: (UserProfile::MAX_UIDS_PER_REQUEST+1..UserProfile::MAX_UIDS_PER_REQUEST+10).to_a.join(","), fields: UserProfile::FIELDS}).and_return([3,4])
        UserProfile.stub(:fetch_from_api_response) {|x| x}
        UserProfile.fetch(uids: uids, api: @api).should == [1,2,3,4]
      end
    end
    
    context "::fetch(uids:1, save: true)" do
      it "persists the object" do
        api=double("api")
        api.stub(:users_get)
        profile=double "profile"
        UserProfile.stub(:fetch_from_api_response).and_return([profile,profile,profile])
        profile.should_receive(:save).exactly(3).times
        UserProfile.fetch(uids: [1,2,3], api: api, save: true)
      end
    end
  end

  context "::fetch_from_api_response" do
    it "creates new UserProfile with filled attributes" do
      profile=UserProfile.fetch_from_api_response(RESPONSE)
      PROFILE.each do |key, value|
        profile[key].should==value
      end
    end

    context "::fetch(response, save: true)" do
      it "persists the object" do
        UserProfile.fetch_from_api_response({response: [{},{}]}, save: true)
        UserProfile.all.count.should==2
      end
    end

    context "response from vk is not {response: ... }" do
      it "raises error" do
        expect {UserProfile.fetch_from_api_response({error: [{}]})}.to raise_error
      end
    end
    
  end
end
