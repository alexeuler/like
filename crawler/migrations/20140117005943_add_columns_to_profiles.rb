class AddColumnsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :city, :string
    add_column :profiles, :country, :string
    add_column :profiles, :rate, :string
    add_column :profiles, :contacts, :string
    add_column :profiles, :has_mobile, :string
    add_column :profiles, :albums_count, :integer
    add_column :profiles, :videos_count, :integer
    add_column :profiles, :audios_count, :integer
    add_column :profiles, :notes_count, :integer
    add_column :profiles, :photos_count, :integer
    add_column :profiles, :groups_count, :integer
    add_column :profiles, :friends_count, :integer
    add_column :profiles, :online_friends_count, :integer
    add_column :profiles, :user_videos_count, :integer
    add_column :profiles, :followers_count, :integer
  end
end
