class AddMoreColumnsToSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :special_offers, :is_redeemed, :boolean
    add_column :special_offers, :redeem_code, :integer
  end
end
