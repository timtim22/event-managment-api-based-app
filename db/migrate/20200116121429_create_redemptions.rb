class CreateRedemptions < ActiveRecord::Migration[5.2]
  def change
    create_table :redemptions do |t|
      t.integer :user_id
      t.string :pass_id
      t.integer :code, default: 0
      t.timestamps
    end
  end
end
