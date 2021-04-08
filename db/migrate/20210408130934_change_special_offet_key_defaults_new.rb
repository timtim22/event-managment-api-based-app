class ChangeSpecialOffetKeyDefaultsNew < ActiveRecord::Migration[5.2]
  def change
  	remove_column :special_offers, :start_time
  	remove_column :special_offers, :end_time
  	add_column :special_offers, :start_time, :datetime, default: ""
  	add_column :special_offers, :end_time, :datetime, default: ""
  end
end
