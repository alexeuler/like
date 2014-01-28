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
    get_likes posts
    user=UserProfile.fetch(uids: id, save: true)
    user.fetch_friends(uids: id, save: true)
  end

  def get_likes(posts)
    posts.each do |post| 
      uids=post.fetch_like_uids
      fetched=UserProfile.find_all_by_vk_id(uids).map(&:vk_id)
      uids.delete_if { |uid| fetched.include? uid }
      profiles=UserProfile.fetch(uids: uids, save: true)
      post.profiles << profiles
      post.save
    end
  end
end
