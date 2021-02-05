class RefineEventsSchema < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :name, :tiile
    remove_column :events, :host
    remove_column :events, :lat
    remove_column :events, :lng
    remove_column :events, :invitees
    remove_column :events, :placeholder
    remove_column :events, :price_range
    remove_column :events, :is_cancelled
    remove_column :events, :video
    remove_column :events, :quantity
  end
end
