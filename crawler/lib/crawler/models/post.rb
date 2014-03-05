require_relative "fetchable"
require_relative "mapping"

module Crawler
  module Models
    class Post < ActiveRecord::Base
      extend Fetchable
      fetcher :wall_get, :owner_id, Mapping.post

      validates_uniqueness_of :vk_id, scope: :owner_id

      has_many :likes
      has_many :likes_user_profiles, through: :likes, source: "user_profile"

      def fetch_likes
        user_ids=Like.fetch([vk_id, owner_id]).map(&:user_profile_id)
        users = UserProfile.load_or_fetch(user_ids)
        self.likes_user_profiles = users
        users
      end
    end
  end
end