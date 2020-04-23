class AddColumnToChatChannels < ActiveRecord::Migration[5.2]
  def change
    add_column :chat_channels, :push_token, :string
  end
end
