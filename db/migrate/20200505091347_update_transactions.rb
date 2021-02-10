class UpdateTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :stripe_response, :json, default: '{}'
    add_column :transactions, :ticket_id, Integer
    remove_column :transactions, :payee_id
    remove_column :transactions, :payment_id
  end
end
