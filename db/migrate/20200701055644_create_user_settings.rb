class CreateUserSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_settings do |t|
      t.integer :user_id
      t.string :name, default: 'setting'
      t.integer :resource_id
      t.boolean :is_on, default: false

      t.timestamps
    end
  end
end
