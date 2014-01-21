class ChangeAttachmentTypePosts < ActiveRecord::Migration
  def change
    change_column :posts, :attachment_type, :string
  end
end
