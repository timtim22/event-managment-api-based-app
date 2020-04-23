class AddColumnToLocationRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :location_requests, :notification_id, :integer
  end
end
