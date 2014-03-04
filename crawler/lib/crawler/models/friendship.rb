module Crawler
  module Models
    class Friendship < ActiveRecord::Base
      extend Fetchable
      fetcher :friends_get, :uid, Mapping.friendship

      belongs_to :user_profile
      belongs_to :friend, class_name: "UserProfile"
    end
  end
end
