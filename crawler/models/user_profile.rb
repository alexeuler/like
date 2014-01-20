require "active_record"
class UserProfile < ActiveRecord::Base
    FIELDS="uid,first_name,last_name,nickname,screen_name,sex,bdate,city,country,timezone,photo,photo_medium,photo_big,has_mobile,rate,contacts,education,online,counters"
    MAX_UIDS_PER_REQUEST=1000

    def self.fetch(uids, api)
      uids=[uids] unless uids.class.name=="Array"
      uids=uids[0..MAX_UIDS_PER_REQUEST-1]
      api.users_get uids: uids.join(","), fields:FIELDS
    end

  end
  
