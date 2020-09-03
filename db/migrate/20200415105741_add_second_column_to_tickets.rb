class AddSecondColumnToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :redeem_code, :integer
  end
end
