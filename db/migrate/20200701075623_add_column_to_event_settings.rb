class AddColumnToEventSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :event_settings, :is_blocked, :boolean, default: false
  end
end
