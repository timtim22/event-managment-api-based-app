class RemoveSrtartTimeAndEndTimeFromCompetition < ActiveRecord::Migration[5.2]
  def change
  	remove_column :competitions, :start_time
  	remove_column :competitions, :end_time

  end
end
