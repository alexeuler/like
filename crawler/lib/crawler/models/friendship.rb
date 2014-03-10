module Crawler
  module Models
    class Friendship < ActiveRecord::Base
      extend Fetchable
      fetcher :friends_get, :uid, Mapping.friendship

      belongs_to :user_profile
      belongs_to :friend, class_name: "UserProfile"

      @@mutex = Mutex.new

      def self.mass_insert_primary(uids, id)
        @@mutex.lock
        in_db = self.where(user_profile_id: id).where(friend_id: uids).to_a
        uids_to_db = uids - in_db.map(&:friend_id)
        to_db = []
        uids_to_db.each do |uid|
          to_db << self.create(user_profile_id: id, friend_id: uid)
        end
        @@mutex.unlock
        in_db + to_db
      end

    end
  end
end
