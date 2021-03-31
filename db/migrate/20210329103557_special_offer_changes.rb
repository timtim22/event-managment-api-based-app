class SpecialOfferChanges < ActiveRecord::Migration[5.2]
  def change
  	add_column :special_offers, :over_18, :boolean, default: true
  	add_column :special_offers, :limited, :boolean, default: true
  	add_column :special_offers, :start_time, :datetime
  	remove_column :special_offers, :date
  	remove_column :special_offers, :time
  end
end
