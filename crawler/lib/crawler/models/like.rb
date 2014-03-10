module Crawler
  module Models
    class Like < ActiveRecord::Base
      #Fetch method returns an array of Like models with user_profile_id
      # set to vk_id of UserProfile
      extend Fetchable
      fetcher :likes_getList, [:item_id, :owner_id], Mapping.like

      belongs_to :user_profile
      belongs_to :post

      @@mutex = Mutex.new

      def self.mass_insert(uids, post_id)
        @@mutex.lock
        in_db = self.where(post_id: post_id).where(user_profile_id: uids).to_a
        uids_to_db = uids - in_db.map(&:user_profile_id)
        to_db = []
        uids_to_db.each do |uid|
          to_db << self.create(user_profile_id: uid, post_id: post_id)
        end
        @@mutex.unlock
        in_db + to_db
      end

    end
  end
end
