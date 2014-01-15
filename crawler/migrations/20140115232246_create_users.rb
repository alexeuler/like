class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :vk_id, null: false
      t.string :first_name
      t.string :last_name
      t.integer :access_mask, default: 0
      t.string :photo
      t.integer :sex
      t.date :birthday
      t.string :university
      t.string :faculty
      t.timestamps
    end
  end
end
