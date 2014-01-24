class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.integer :user_profile_id
      t.integer :friend_id
    end
  end
end
