class CreateViews < ActiveRecord::Migration[5.2]
  def change
    create_table :views do |t|
      t.integer :user_id
      t.integer :resource_id
      t.string :resource_type

      t.timestamps
    end
  end
end
