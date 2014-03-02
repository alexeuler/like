module Crawler
  module Models
    class Friendship < ActiveRecord::Base
      belongs_to :user_profile
      belongs_to :friend, class_name: "UserProfile"
    end
  end
end
