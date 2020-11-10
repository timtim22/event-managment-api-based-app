class AddIsRedeemedColumnToWallets < ActiveRecord::Migration[5.2]
  def change
    add_column :wallets, :is_redeemed, :boolean, default: false
  end
end
