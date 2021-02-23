class ChangesDateFormatInEvents < ActiveRecord::Migration[5.2]
  def change
 	remove_column :events, :start_date
 	remove_column :events, :end_date
 	remove_column :child_events, :start_date
 	remove_column :child_events, :end_date
  end
end
