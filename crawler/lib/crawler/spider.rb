require 'celluloid'
require_relative "../config/db"
require_relative "vk_api"

module Crawler
  class Spider
    include Celluloid

    MIN_LIKES = 5
    JOB_SIZE = 10000

    @@mutex = Mutex.new

    def initialize(args = {})
      @active = true
      @number = args[:number]
      async.start
    end

    def log(message = "")
      puts "#{Time.now.strftime('%H - %M - %S # %L')} : #{message}. Thread : #{Thread.current[:number]}"
    end

    def start
      #connection = ActiveRecord::Base.connection_pool.checkout
      Thread.current[:number] = @number
      begin
        while @active
          @api = VkApi.new
          user = get_job
          break if user.nil?
          log "fetch post"
          posts = Post.fetch(user.vk_id)
          log "in memory"
          posts = posts.is_a?(Array) ? posts : [posts]
          posts = posts.select { |x| x.likes_count >= MIN_LIKES }
          log "save post"
          posts.each do |post|
            post.save
            post.fetch_likes
          end
          log "fetch friends"
          user.fetch_friends
          log "fetch user"
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