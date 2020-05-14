class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.string :payment_id
      t.integer :payee_id
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
