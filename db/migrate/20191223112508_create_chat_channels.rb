class CreateChatChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :chat_channels do |t|
      t.integer :recipient_id
      t.string  :name
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
