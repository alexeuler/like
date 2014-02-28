class CreateUserProfile < ActiveRecord::Migration
  def change
    create_table "user_profiles", force: true do |t|
      t.integer "vk_id", null: false
      t.string "first_name"
      t.string "last_name"
      t.integer "access_mask", default: 0
      t.string "photo"
      t.integer "sex"
      t.date "birthday"
      t.integer "university"
      t.integer "faculty"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "city"
      t.integer "country"
      t.integer "has_mobile"
      t.integer "albums_count"
      t.integer "videos_count"
      t.integer "audios_count"
      t.integer "notes_count"
      t.integer "photos_count"
      t.integer "groups_count"
      t.integer "friends_count"
      t.integer "online_friends_count"
      t.integer "user_videos_count"
      t.integer "followers_count"
      t.integer "status", default: 0
    end
  end
end
