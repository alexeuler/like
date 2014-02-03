class AddStatusToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :status, :integer, default: 0
  end
end
