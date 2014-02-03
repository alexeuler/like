class ChangeVkIdTypeInPosts < ActiveRecord::Migration
  def change
    change_column :posts, :vk_id, :integer
  end
end
