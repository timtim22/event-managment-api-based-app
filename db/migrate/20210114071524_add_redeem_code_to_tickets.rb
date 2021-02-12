class AddRedeemCodeToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :qr_code, :string, default: ""
  end
end
