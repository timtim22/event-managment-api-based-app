class AddColumnsToOfferForwarding < ActiveRecord::Migration[5.2]
  def change
    add_column :offer_forwardings, :is_ambassador, :boolean, default: false
    add_column :offer_shares, :is_ambassador, :boolean, default: false
  end
end
