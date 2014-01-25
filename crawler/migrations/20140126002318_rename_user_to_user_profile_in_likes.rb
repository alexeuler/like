class RenameUserToUserProfileInLikes < ActiveRecord::Migration
  def change
    rename_column :likes, :user_id, :user_profile_id
  end
end
