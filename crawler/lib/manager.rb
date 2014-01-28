require_relative "../models/post"
require_relative "../models/frontier"
class Manager
  MAX_POSTS=500_000

  def get_work
    return nil if stop?
    Frontier.pull
  end
  
  def done(vk_id)
    Frontier.where(vk_id: vk_id).delete_all
  end
  
  def stop?
    Post.count >= MAX_POSTS
  end
end
