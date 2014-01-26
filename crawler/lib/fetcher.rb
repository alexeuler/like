require "celluloid"
require_relative "vk_api"
require_relative "../models/user_profile"
require_relative "../models/post"
class Fetcher
  include Celluloid
  def initialize(args={})
    @socket=args[:socket]
    @manager=args[:manager]
  end

  def start
    catch :done do
      loop do
        id=@manager.get_work
        user=UserProfile.fetch(uids: id, save: true)
        posts=Post.fetch(uids: id, save: true)
        friends=user.fetch_friends(uids: id, save: true)
        @manager.push(friends) unless @manager.full_frontier?
        @manager.done(id)
      end
    end
  end

end
