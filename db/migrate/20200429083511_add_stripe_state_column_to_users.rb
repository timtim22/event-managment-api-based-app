class AddStripeStateColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :stripe_state, :string, :default => 'no state' 
    add_column :users, :connected_account_id, :string, :default => 'no account'
  end
end
