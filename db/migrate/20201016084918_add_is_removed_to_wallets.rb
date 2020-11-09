class AddIsRemovedToWallets < ActiveRecord::Migration[5.2]
  def change
    add_column :wallets, :is_removed, :boolean, default: false
  end
end
