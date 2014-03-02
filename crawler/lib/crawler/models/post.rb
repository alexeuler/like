require_relative "fetchable"
require_relative "mapping"

module Crawler
  module Models
    class Post < ActiveRecord::Base
      extend Fetchable
      fetcher :wall_get, :owner_id, Mapping.post
    end
  end
end