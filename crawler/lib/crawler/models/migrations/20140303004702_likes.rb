class Likes < ActiveRecord::Migration
  def change
    create_table "likes", force: true do |t|
      t.integer "post_id", null: false
      t.integer "user_profile_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end

