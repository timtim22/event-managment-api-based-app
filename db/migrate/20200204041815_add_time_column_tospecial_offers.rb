class AddTimeColumnTospecialOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :special_offers, :time, :datetime
  end
end
