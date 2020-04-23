class CreateOfferShares < ActiveRecord::Migration[5.2]
  def change
    create_table :offer_shares do |t|
      t.integer :user_id
      t.integer :recipient_id
      t.string :offer_type
      t.integer :offer_id

      t.timestamps
    end
  end
end
