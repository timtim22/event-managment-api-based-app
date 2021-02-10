class AddColumnToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :payee_id, Integer
    add_column :transactions, :amount, Integer
  end
end
