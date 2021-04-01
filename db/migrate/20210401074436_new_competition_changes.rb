class NewCompetitionChanges < ActiveRecord::Migration[5.2]
  def change
  	add_column :competitions, :status, :string, default: ""
  	add_column :competitions, :draw_time, :datetime
  	remove_column :competitions, :start_date
  	remove_column :competitions, :start_time
  	remove_column :competitions, :end_date
  	remove_column :competitions, :end_time
  end
end
