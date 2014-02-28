require_relative "fetchable"
require_relative "mapping"

module Crawler
  module Models
    class UserProfile < ActiveRecord::Base
      extend Fetchable
      fetcher :users_get, :uids, Mapping.user_profile
    end
  end
end
