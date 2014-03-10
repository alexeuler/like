require 'celluloid'
require_relative "../config/db"
require_relative "vk_api"

module Crawler
  class Spider
    include Celluloid

    MIN_LIKES = 5
    JOB_SIZE = 10000

    def initialize(args = {})
      @active = true
      async.start
    end

    def start
      begin
        connection = ActiveRecord::Base.connection_pool.checkout
        user = nil
        while @active
          @api = VkApi.new
#ToDo: set status as in-process
          user = get_job
          break if user.nil?
#ToDo: one post could be returned
          posts = Post.fetch(user.vk_id)
          posts = posts.select { |x| x.likes_count >= MIN_LIKES }
          posts.each do |post|
            post.save
            post.fetch_likes
          end
          user.fetch_friends
          user.status = 1
          user.save
        end
      ensure
        begin
          user.status=2
          user.save
        rescue Exception => e
          puts "Unable to save user with error status. Error: #{e.message}"
        end
        ActiveRecord::Base.connection_pool.checkin(connection)
      end

    end

    private

    def get_job
      return nil if UserProfile.where(status: 1).count > JOB_SIZE
      UserProfile.where(status: 0).first
    end

  end
end