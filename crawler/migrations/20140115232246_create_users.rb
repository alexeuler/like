class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :vk_id


      
      t.integer  :installed_app
      t.string  :label
      t.text    :value
      t.string  :type
      t.integer :position
    end
end
