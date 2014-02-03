class AddAttachTitleToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :attachment_title, :integer 
  end
end
