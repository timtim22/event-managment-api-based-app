class SetDefaultsOnTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:transactions, :stripe_response, from: '{}', to: nil)
  end
end
