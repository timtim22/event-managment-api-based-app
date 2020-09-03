class EditSchemaOfTickets < ActiveRecord::Migration[5.2]
  def change

    add_column :tickets, :start_price, :integer, default: 0
    add_column :tickets, :end_price, :integer, default: 0
    remove_column :tickets, :redeem_code
  end
end
