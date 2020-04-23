class AddFieldsToEvents < ActiveRecord::Migration[5.2]
  def change
  	add_column :events, :location, :string
  	add_column :events, :over_18, :boolean, :default => 0
  	add_column :events, :event_forwarding, :boolean, :default => 0
  	add_column :events, :allow_chat, :boolean, :default => 0
  	add_column :events, :allow_additional_media, :boolean, :default => 0
  	add_column :events, :invitees, :integer, :default => 0
  end
end
