class AddRedeemCodeToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :redeem_code, :string, default: ""
  end
end
