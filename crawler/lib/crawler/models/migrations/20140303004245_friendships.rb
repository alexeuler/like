class Friendships < ActiveRecord::Migration
  def change
    create_table "friendships", force: true do |t|
      t.integer "user_profile_id"
      t.integer "friend_id"
    end
  end
end
