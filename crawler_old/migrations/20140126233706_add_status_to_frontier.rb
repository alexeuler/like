class AddStatusToFrontier < ActiveRecord::Migration
  def change
    add_column :frontiers, :status, :integer, default: 0
    change_column :frontiers, :vk_id, :integer, null: false
  end
end
