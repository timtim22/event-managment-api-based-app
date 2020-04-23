class AddColumnToLocationShares < ActiveRecord::Migration[5.2]
  def change
    add_column :location_shares, :notification_id, :integer
  end
end
