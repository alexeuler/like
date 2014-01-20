require "active_record"
class UserProfile < ActiveRecord::Base
  FIELDS="uid,first_name,last_name,nickname,screen_name,sex,bdate,city,country,timezone,photo,photo_medium,photo_big,has_mobile,rate,contacts,education,online,counters"
  MAX_UIDS_PER_REQUEST=1000

  def self.fetch(args={})
    uids=args[:uids]
    api=args[:api] || @@api
    uids=[uids] unless uids.class.name=="Array"
    uids=uids[0..MAX_UIDS_PER_REQUEST-1]
    result=api.users_get uids: uids.join(","), fields:FIELDS
    fetch_from_api_response(result)
  end

  def self.fetch_from_api_response(data)
    
  end

end

