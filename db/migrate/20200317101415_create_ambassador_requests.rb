class CreateAmbassadorRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :ambassador_requests do |t|
      t.integer :user_id
      t.integer :business_id
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
