class AddLocationEnabledToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :location_enabled, :boolean
  end
end
