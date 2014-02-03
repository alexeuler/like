class ChangeUserProfilesTypes < ActiveRecord::Migration
  def change
    change_column :user_profiles, :vk_id, :integer
    change_column :user_profiles, :university, :integer
    change_column :user_profiles, :faculty, :integer
    change_column :user_profiles, :city, :integer
    change_column :user_profiles, :country, :integer
    change_column :user_profiles, :has_mobile, :integer
  end
end
