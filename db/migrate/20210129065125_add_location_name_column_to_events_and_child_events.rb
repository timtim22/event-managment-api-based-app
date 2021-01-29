class AddLocationNameColumnToEventsAndChildEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :location_name, :string, default: "no_location"
    add_column :child_events, :location_name, :string, default: "no_location"
  end
end
