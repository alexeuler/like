require 'celluloid'
require_relative "../config/db"
require_relative "vk_api"
require_relative "logging"

module Crawler
  class Spider
    include Celluloid
    include Logging

    MIN_LIKES = 5
    JOB_SIZE = 10000

    @@mutex = Mutex.new

    def initialize(args = {})
      @active = true
      @number = args[:number]
      async.start
    end

    def start
      #connection = ActiveRecord::Base.connection_pool.checkout
      Thread.current[:number] = @number
      begin
        while @active
          @api = VkApi.new
          user = get_job
          break if user.nil?
          log "Spider: fetching wall posts"
          posts = Post.fetch(user.vk_id)
          log "Spider: In-memory posts processing"
          posts = posts.is_a?(Array) ? posts : [posts]
          posts = posts.select { |x| x.likes_count >= MIN_LIKES }
          log "Spider: Saving #{posts.count} posts"
          ActiveRecord::Base.transaction do
            posts.each do |post|
              post.save
            end
          end
          log "Spider: Fetching likes"
          posts.each do |post|
            post.fetch_likes
          end
          log "Spider: Fetching friends"
          user.fetch_friends
          log "Spider: Updating user status"
          user.status = 1
          user.save
        end
      ensure
        # ActiveRecord::Base.connection_pool.checkin(connection)
      end

    end

    private

    def get_job
      return nil if UserProfile.where(status: 1).count > JOB_SIZE
      user = nil
      @@mutex.synchronize do
        user = UserProfile.where(status: 0).first
        user.status = 2
        user.save
      end
      user
    end

  end
end