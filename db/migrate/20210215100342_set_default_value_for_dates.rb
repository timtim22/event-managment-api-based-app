class SetDefaultValueForDates < ActiveRecord::Migration[5.2]
  def change
  	change_column :events, :start_date, :string, default: ""
  	change_column :events, :end_date, :string, default: ""
  end
end
