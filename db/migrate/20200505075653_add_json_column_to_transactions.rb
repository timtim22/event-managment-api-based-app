class AddJsonColumnToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :payment_intent, :json
  end
end
