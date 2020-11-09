class CreateVipPassShares < ActiveRecord::Migration[5.2]
  def change
    create_table :vip_pass_shares do |t|
      t.integer :pass_id
      t.integer :user_id

      t.timestamps
    end
  end
end
