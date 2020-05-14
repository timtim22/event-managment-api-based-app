class AddColumnToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :payee_id, :integer
    add_column :transactions, :amount, :integer
  end
end
