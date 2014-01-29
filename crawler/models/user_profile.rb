require "active_record"
class UserProfile < ActiveRecord::Base

  class << self
    attr_accessor :api
  end

  
  has_many :likes
  has_many :likes_posts, through: :likes, source: "post"
  
  has_many :primary_friendships, :class_name => "Friendship", :foreign_key => "user_profile_id"
  has_many :primary_friends, through: :primary_friendships, :source => :friend
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user_profile

  
  
  def friends
    primary_friends+inverse_friends
  end

  def add_friends(user_profiles)
    common=friends & user_profiles
    user_profiles.delete_if {|x| common.include? x}
    primary_friends << user_profiles
  end
  
  FIELDS="uid,first_name,last_name,nickname,screen_name,sex,bdate,city,country,timezone,photo,photo_medium,photo_big,has_mobile,rate,contacts,education,online,counters"
  MAX_UIDS_PER_REQUEST=100 #In theory it is allowed to do 1000 uids, however vk denies if you do these often, 100 is a pretty safe level
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

  #Usage:
  #UserProfile.fetch (uids: [1,2])
  #UserProfile.fetch (uids: 1, api: api, save: true)

  def self.fetch(args={})
    uids=args[:uids]
    args[:api] && api=args[:api]
    uids=[uids] unless uids.class.name=="Array"
    profile_chunks=[]
    profile_chunks_count=uids.count / MAX_UIDS_PER_REQUEST + 1
    profile_chunks_count.times do |i| 
      uids_cut=uids[MAX_UIDS_PER_REQUEST*i..MAX_UIDS_PER_REQUEST*(i+1)-1]
      result=api.users_get uids: uids_cut.join(","), fields:FIELDS
      profile=fetch_from_api_response(result)
      profile.each {|p| p.save } if args[:save]
      profile_chunks << profile
    end
    profile_chunks.inject {|sum,x| sum+x}
  end

  #Usage:
  #UserProfile.fetch_from_api_response ("{response: ...}", save: true)
  
  def self.fetch_from_api_response(data, args={})
    raise "Error: invalid response. #{data}" unless data[:response]
    results=[]
    data[:response].each do |response|
      result=self.where(vk_id: response[:uid]).first_or_create
      Mapping.each do |key,value|
        value = key=~/_count$/ ? response[:counters] && response[:counters][value] : response[value]
        value=value.to_i if INTEGERS.include? key.to_s
        result.send "#{key}=".to_sym, value
      end
      result.status=1           # fetched
      results << result
    end
    results.each {|res| res.save} if args[:save]
    results.count > 1 ?  results : results[0]
  end

end

