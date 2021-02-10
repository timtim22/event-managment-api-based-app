class AddChildEventIdToReplies < ActiveRecord::Migration[5.2]
  def change
    add_column :replies, :child_event_id, Integer
  end
end
