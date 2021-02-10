class AddChildEventIdToReminders < ActiveRecord::Migration[5.2]
  def change
    add_column :reminders, :child_event_id, Integer
  end
end
