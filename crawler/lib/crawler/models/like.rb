module Crawler
  module Models
    class Like < ActiveRecord::Base
      #Fetch method returns an array of Like models with user_profile_id
      # set to vk_id of UserProfile
      extend Fetchable
      fetcher :likes_getList, [:item_id, :owner_id], Mapping.like

      belongs_to :user_profile
      belongs_to :post
    end
  end
end
