class AddQuantityToWallets < ActiveRecord::Migration[5.2]
  def change
    add_column :wallets, :quantity, Integer, default: 1
  end
end
