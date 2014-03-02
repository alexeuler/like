module Crawler
  module Models
    class Like < ActiveRecord::Base
      extend Fetchable
      fetcher :likes_getList, [:item_id, :owner_id], Mapping.like

      belongs_to :user_profile
      belongs_to :post
    end
  end
end
