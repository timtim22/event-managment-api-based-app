class CreateLocationShares < ActiveRecord::Migration[5.2]
  def change
    create_table :location_shares do |t|
      t.integer :user_id
      t.integer :recipient_id
      t.string :lat, default: ''
      t.string :lng, default: ''

      t.timestamps
    end
  end
end
