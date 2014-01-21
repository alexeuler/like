class RemoveRateContactsFromUserProfiles < ActiveRecord::Migration
  def change
    remove_column :user_profiles, :rate
    remove_column :user_profiles, :contacts
  end
end
