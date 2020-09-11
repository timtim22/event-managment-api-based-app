class Redemptions < ActiveRecord::Migration[5.2]
  def change
    create_table :redemptions do |t|
      t.integer :user_id
      t.integer :offer_id
      t.string :offer_type
      t.integer :code, default: 0
      t.timestamps
    end
  end
end
