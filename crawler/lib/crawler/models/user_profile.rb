require_relative "fetchable"
require_relative "mapping"

module Crawler
  module Models
    class UserProfile < ActiveRecord::Base
      extend Fetchable
      fetcher :users_get, :uids, Mapping.user_profile
      MAX_PROFILES_PER_FETCH = 100

      validates_uniqueness_of :vk_id

      has_many :posts, primary_key: "vk_id", foreign_key: "owner_id"
      has_many :primary_friendships, :class_name => "Friendship", :foreign_key => "user_profile_id"
      has_many :primary_friends, through: :primary_friendships, :source => :friend
      has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
      has_many :inverse_friends, :through => :inverse_friendships, :source => :user_profile

      has_many :likes
      has_many :likes_posts, through: :likes, source: "post"

      @@mutex = Mutex.new

      def friends
        primary_friends + inverse_friends
      end

      def self.load_or_fetch(id)
        ids = id.is_a?(Array) ? id : [id]
        models = UserProfile.where(vk_id: ids).to_a
        existing = models.map(&:vk_id)
        new = ids - existing
        ((new.count-1) / MAX_PROFILES_PER_FETCH + 1).times do |i|
          ids_to_fetch = new[i*MAX_PROFILES_PER_FETCH..(i+1)*MAX_PROFILES_PER_FETCH - 1]
          fetched = UserProfile.fetch(ids_to_fetch)
          fetched = [fetched] unless fetched.is_a?(Array)
          models += fetched
        end
        models
      end

      def fetch_friends
        ids = Friendship.fetch(vk_id).map(&:user_profile_id)
        users = self.class.load_or_fetch(ids)
        users -= inverse_friends
        users = self.class.mass_insert(users)
        Friendship.mass_insert_primary(users.map(&:id), self.id)
        users
      end

      def self.mass_insert(users)
        @@mutex.lock
        users_to_save = users.select { |u| u.id.nil? }
        ids = users_to_save.map(&:vk_id)
        users_in_db = self.where(vk_id: ids).to_a
        users_in_db_ids = users_in_db.map(&:vk_id)
        users_to_db = users_to_save.map { |u| users_in_db_ids.include?(u.vk_id) ? nil : u }
        users_to_db.compact!
        users_to_db.each do |u|
          u.save
        end
        @@mutex.unlock
        result = users - users_to_save + users_in_db + users_to_db
        result
      end

    end
  end
end
