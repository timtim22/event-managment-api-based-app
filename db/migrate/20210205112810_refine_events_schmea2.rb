class RefineEventsSchmea2 < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :tiile, :title
    rename_column :child_events, :name, :title
    remove_column :child_events, :host
    remove_column :child_events, :lat
    remove_column :child_events, :lng
    remove_column :child_events, :invitees
    remove_column :child_events, :placeholder
    remove_column :child_events, :is_cancelled
    remove_column :child_events, :start_time
    remove_column :child_events, :end_time
    remove_column :events, :start_time
    remove_column :events, :end_time
  end
end
