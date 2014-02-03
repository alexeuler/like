require "celluloid"
require_relative "vk_api"
require_relative "../models/user_profile"
require_relative "../models/post"
class Fetcher

  MIN_LIKES=3
  
  include Celluloid
  attr_accessor :manager, :socket
  
  def initialize(args={})
    @manager=args[:manager]
  end

  def start
    while id=manager.get_work do
      new_work=fetch(id)
      manager.push(new_work) unless manager.full_frontier?
      manager.done(id)
    end
  end

  def fetch(id)
    posts=Post.fetch(uids: id, save: true, min_likes: MIN_LIKES)
    posts.each { |post| post.fetch_likes(with_profiles: true)  }
    user=UserProfile.fetch(uids: id, save: true)
    user.fetch_friends(uids: id, save: true)
  end

end
