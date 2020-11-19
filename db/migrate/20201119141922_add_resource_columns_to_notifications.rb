class AddResourceColumnsToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :resource_id, :integer
    add_column :notifications, :resource_type, :string
  end
end
