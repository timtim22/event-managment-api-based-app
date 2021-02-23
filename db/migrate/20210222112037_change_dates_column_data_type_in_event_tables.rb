class ChangeDatesColumnDataTypeInEventTables < ActiveRecord::Migration[5.2]
  def change
 	change_column :events, :start_date, :datetime
 	change_column :events, :end_date, :datetime
 	change_column :child_events, :start_date, :datetime
 	change_column :child_events, :end_date, :datetime
  end
end
