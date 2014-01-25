class ChangeIdTypesInLikes < ActiveRecord::Migration
  def change
    change_column :likes, :user_profile_id, :integer
    change_column :likes, :post_id, :integer
  end
end
