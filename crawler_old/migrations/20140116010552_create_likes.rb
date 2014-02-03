class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.string :post_id, null: false
      t.string :user_id, null: false
      t.timestamps
    end
  end
end
