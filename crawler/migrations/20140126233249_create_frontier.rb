class CreateFrontier < ActiveRecord::Migration
  def change
    create_table :frontiers do |t| 
      t.integer :vk_id
      t.timestamps
    end
  end
end
