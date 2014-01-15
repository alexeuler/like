class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.integer :vk_id, null: false
      t.integer :friend_id, null: false
      t.timestamps
    end
  end
end
