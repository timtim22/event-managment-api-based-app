class AddChildEventIdToComments < ActiveRecord::Migration[5.2]
  def change
  	add_column :comments, :child_event_id, Integer
  	add_column :views, :child_event_id, Integer
  	add_column :interest_levels, :child_event_id, Integer
  	add_column :event_shares, :child_event_id, Integer
  	add_column :event_forwardings, :child_event_id, Integer
  end
end
