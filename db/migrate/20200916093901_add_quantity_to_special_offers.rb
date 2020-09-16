class AddQuantityToSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :special_offers, :quantity, :integer, default: 0
  end
end
