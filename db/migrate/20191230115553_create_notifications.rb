class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.integer :recipient_id
      t.integer :actor_id
      t.integer :notifiable_id
      t.string :notifiable_type
      t.text :data
      t.string :action
      t.datetime :read_at
      t.timestamps
    end
  end
end
