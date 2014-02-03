class ChangeAttachmentTitlePosts < ActiveRecord::Migration
  def change
    change_column :posts, :attachment_title, :string
  end
end
