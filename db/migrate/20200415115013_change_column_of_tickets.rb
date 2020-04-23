class ChangeColumnOfTickets < ActiveRecord::Migration[5.2]
  def change
    change_column :tickets, :redeem_code, :string
  end
end
