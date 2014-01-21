class AddAttachIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :attachment_id, :integer
  end
end
