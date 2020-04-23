class ChangeOneColumTypeOfSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    change_column :special_offers, :redeem_code, :string
  end
end
