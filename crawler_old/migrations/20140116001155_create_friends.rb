class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.string :vk_id, null: false
      t.string :friend_id, null: false
      t.timestamps
    end
  end
end
