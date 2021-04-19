class AddMessageTypeToChats < ActiveRecord::Migration[5.2]
  def change
	add_column :messages, :message_type, :string, default: "text"
	add_column :messages, :image, :string, default: ""
  end
end
