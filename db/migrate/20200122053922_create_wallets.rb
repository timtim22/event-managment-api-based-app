class CreateWallets < ActiveRecord::Migration[5.2]
  def change
    create_table :wallets do |t|
      t.integer :offer_id
      t.integer :user_id
      t.string :offer_type
      t.timestamps
    end
  end
end
