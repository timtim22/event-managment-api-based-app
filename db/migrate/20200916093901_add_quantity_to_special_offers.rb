class AddQuantityToSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :special_offers, :quantity, Integer, default: 0
  end
end
