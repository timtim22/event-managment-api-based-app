class SetDefaultValueForChildDates < ActiveRecord::Migration[5.2]
  def change
  	change_column :child_events, :start_date, :string, default: ""
  	change_column :child_events, :end_date, :string, default: ""
  end
end
