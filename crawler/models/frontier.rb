class Frontier < ActiveRecord::Base

  BUSY_TIMEOUT=86400               # in seconds
  
  def self.pull
    self.free_busy
    frontier=self.where(status: 0).first
    frontier.status=1
    frontier.save
    frontier.vk_id
  end

  def self.done(vk_id)
    self.where(vk_id: vk_id).delete_all
  end
  
  private
  
  def self.free_busy
    busy=self.where(status: 0)
    busy.each do |busy_frontier| 
      if Time.now-busy_frontier.updated_at > BUSY_TIMEOUT
        busy_frontier.status=0
        busy_frontier.save
      end
    end
  end
  
end
