class ChangeDefaultDateTimeForSpecialOffer < ActiveRecord::Migration[5.2]
  def change
  	remove_column :competitions, :draw_time, null: false
  	add_column :competitions, :draw_time, :datetime, null: false, default: 0
  end
end
