class CreateEventSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :event_settings do |t|
      t.integer :event_id
      t.boolean :mute_chat, default: false
      t.boolean :mute_notifications, default: false
      t.integer :user_id

      t.timestamps
    end
  end
end
