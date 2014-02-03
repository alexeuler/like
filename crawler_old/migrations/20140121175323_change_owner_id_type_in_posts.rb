class ChangeOwnerIdTypeInPosts < ActiveRecord::Migration
  def change
    change_column :posts, :owner_id, :integer
  end
end
