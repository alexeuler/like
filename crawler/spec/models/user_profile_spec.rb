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
  vk_id: 20,  #make it int
  first_name:"Sergey",
  last_name:"Zolin",
  photo:"http://cs315126.vk.me/u20/e_sa5c7sdfb1.jpg",
  sex: 2,
  birthday: Date.new(1987, 2, 28),
  university: 2, #make it int
  faculty: 23, #make it int
  city: 1,  #make it int
  country: 1,  #make it int
  has_mobile: 1,  #make it int
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
    it "fecthes user profiles from vk specified by uids parameter" do
      api=double("api")
      api.should_receive(:users_get).with({uids: "1,2,3", fields: UserProfile::FIELDS}).and_return("test")
      UserProfile.should_receive(:fetch_from_api_response).with("test")
      UserProfile.fetch(uids: [1,2,3], api: api)
    end
  end

  context "::fetch_from_api_response" do
    it "creates new UserProfile with filled attributes", now: true do
      profile=UserProfile.fetch_from_api_response(RESPONSE)
      puts profile.to_yaml
      PROFILE.each do |key, value|
        puts key
        profile[key].should==value
      end
    end
  end
end
