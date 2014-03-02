require_relative "fetchable"
require_relative "mapping"

module Crawler
  module Models
    class Post < ActiveRecord::Base
      extend Fetchable
      fetcher :wall_get, :owner_id, Mapping.post

      has_many :likes
      has_many :likes_user_profiles, through: :likes, source: "user_profile"
    end
  end
end