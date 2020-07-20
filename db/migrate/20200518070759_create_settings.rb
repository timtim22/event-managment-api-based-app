class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.string :name
      t.boolean :is_on, default: true
      t.integer :user_id

      t.timestamps
    end
  end
end
