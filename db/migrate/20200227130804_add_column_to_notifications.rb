class AddColumnToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :action_type, :string
  end
end
