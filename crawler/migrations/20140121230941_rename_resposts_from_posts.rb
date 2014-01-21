class RenameRespostsFromPosts < ActiveRecord::Migration
  def change
    rename_column :posts, :resposts, :reposts_count
    rename_column :posts, :likes, :likes_count
  end
end
