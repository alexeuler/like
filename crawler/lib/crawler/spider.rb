require 'celluloid'
require_relative "../config/db"
require_relative "vk_api"

module Crawler
  class Spider
    include Celluloid

    MIN_LIKES = 5
    JOB_SIZE = 10000

    def initialize(args = {})
      @mutex = args[:mutex]
      @active = true
      async.start
    end

    def start
      begin
        DB.checkout
        while @active
          @api = VkApi.new
          user = get_job
          break if user.nil?
          posts = Post.fetch(user.vk_id)
          posts = posts.select { |x| x.likes_count >= MIN_LIKES }
          posts.each do |post|
            post.fetch_likes(@mutex)
            post.save
          end
          user.fetch_friends(@mutex)
          user.status = 1
          user.save
        end
      ensure
        begin
          user.status=2
          user.save
        rescue
        end
        DB.checkin
      end

    end

    private

    def get_job
      return nil if UserProfile.where(status: 1).count > JOB_SIZE
      UserProfile.where(status: 0).first
    end

  end
end