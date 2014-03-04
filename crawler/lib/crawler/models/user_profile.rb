require_relative "fetchable"
require_relative "mapping"

module Crawler
  module Models
    class UserProfile < ActiveRecord::Base
      extend Fetchable
      fetcher :users_get, :uids, Mapping.user_profile

      has_many :primary_friendships, :class_name => "Friendship", :foreign_key => "user_profile_id"
      has_many :primary_friends, through: :primary_friendships, :source => :friend
      has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
      has_many :inverse_friends, :through => :inverse_friendships, :source => :user_profile

      has_many :likes
      has_many :likes_posts, through: :likes, source: "post"

      def friends
        primary_friends + inverse_friends
      end

      def self.load_or_fetch(id)
        ids = id.is_a?(Array) ? id : [id]
        models = UserProfile.where(vk_id: ids).to_a
        existing = models.map(&:vk_id)
        new = ids - existing
        models += UserProfile.fetch(new)
        models
      end

      def fetch_friends
        ids = Friendship.fetch(vk_id).map(&:user_profile_id)
        users = self.class.load_or_fetch(ids)
        self.primary_friends = users
        users
      end

    end
  end
end
