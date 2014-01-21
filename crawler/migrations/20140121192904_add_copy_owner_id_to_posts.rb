class AddCopyOwnerIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :copy_owner_id, :integer
    add_column :posts, :copy_post_id, :integer
  end
end
