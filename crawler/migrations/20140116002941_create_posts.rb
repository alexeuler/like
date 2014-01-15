class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :vk_id, null: false #original id
      t.string :owner_id, null: false
      t.text :text
      t.integer :attachment_type
      t.string :attachment_image
      t.text :attachment_text
      t.string :attachment_url
      t.integer :likes, default: 0
      t.integer :resposts, default: 0
      t.timestamps
    end
  end
end
