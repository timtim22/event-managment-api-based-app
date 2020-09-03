class AddNewColumnToSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :special_offers, :ambassador_rate, :string, default: '1'
  end
end
