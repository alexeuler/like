require_relative "../models/post"
class Manager
  MAX_POSTS=500_000

  def stop?
    Post.count >= MAX_POSTS
  end
end
