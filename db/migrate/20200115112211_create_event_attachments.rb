class CreateEventAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :event_attachments do |t|
      t.integer :event_id
      t.string :media
      t.string :media_type, default: '0'

      t.timestamps
    end
  end
end
