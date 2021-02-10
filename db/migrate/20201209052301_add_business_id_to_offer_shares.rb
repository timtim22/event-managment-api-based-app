class AddBusinessIdToOfferShares < ActiveRecord::Migration[5.2]
  def change
    add_column :offer_shares, :business_id, Integer
  end
end
