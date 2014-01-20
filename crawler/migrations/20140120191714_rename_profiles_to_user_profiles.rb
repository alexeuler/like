class RenameProfilesToUserProfiles < ActiveRecord::Migration
  def change
    rename_table :profiles, :user_profiles
  end
end
