require 'celluloid'
require_relative "../config/db"
require_relative "vk_api"

module Crawler
  class Spider
    include Celluloid

    MIN_LIKES = 5

    def initialize
      @active = true
    end

    def start
      while @active
        begin
          DB.checkout
          @api = VkApi.new
          user = get_job
          posts = Post.fetch(user.vk_id)
          posts = posts.select { |x| x.likes_count >= MIN_LIKES }
          posts.each do |post|
            post.fetch_likes
            post.save
          end
          user.fetch_friends
          user.status = 1
          user.save
        ensure
          DB.checkin
        end
      end

    end

    private

    def get_job
      UserProfile.where(status: 0).first
    end

  end
end