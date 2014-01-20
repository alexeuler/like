require "active_record"
class UserProfile < ActiveRecord::Base
  FIELDS="uid,first_name,last_name,nickname,screen_name,sex,bdate,city,country,timezone,photo,photo_medium,photo_big,has_mobile,rate,contacts,education,online,counters"
  MAX_UIDS_PER_REQUEST=1000
  Mapping={
    vk_id: :uid,
    first_name: :first_name,
    last_name: :last_name,
    photo: :photo,
    sex: :sex,
    birthday: :bdate,
    university: :university,
    faculty: :faculty,
    city: :city,
    country: :country,
    rate: :rate,
    contacts: :contacts,
    has_mobile: :has_mobile,
    albums_count: :albums,
    videos_count: :videos,
    audios_count: :audios,
    notes_count: :notes,
    photos_count: :photos,
    groups_count: :groups,
    friends_count: :friends,
    online_friends_count: :online_friends,
    user_videos_count: :user_videos,
    followers_count: :followers
  }

  INTEGERS=%w(vk_id sex university faculty city country has_mobile albums_count videos_count audios_count notes_count photos_count groups_count friends_count online_friends_count user_videos_count followers_count)

  def self.fetch(args={})
    uids=args[:uids]
    api=args[:api] || @@api
    uids=[uids] unless uids.class.name=="Array"
    uids=uids[0..MAX_UIDS_PER_REQUEST-1]
    result=api.users_get uids: uids.join(","), fields:FIELDS
    fetch_from_api_response(result)
  end

  def self.fetch_from_api_response(data)
    return unless data[:response]
    results=[]
    data[:response].each do |response|
      result=self.new
      Mapping.each do |key,value|
        value = key=~/_count$/ ? response[:counters][value] : response[value]
        value=value.to_i if INTEGERS.include? key.to_s
        result.send "#{key}=".to_sym, value
      end
      results << result
    end
    results.count > 1 ?  results : results[0]
  end

end

