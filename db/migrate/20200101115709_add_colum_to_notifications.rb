class AddColumToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :url, :string
  end
end
