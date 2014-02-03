class AddAttachOwnerIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :attachment_owner_id, :integer
  end
end
