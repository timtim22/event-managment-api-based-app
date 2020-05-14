class CreateRefundRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :refund_requests do |t|
      t.integer :user_id
      t.integer :business_id
      t.integer :ticket_id
      t.string :status, default: 'pending'
      t.text :reason

      t.timestamps
    end
  end
end
