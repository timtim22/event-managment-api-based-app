class AddPriceColumnToTicketPurchases < ActiveRecord::Migration[5.2]
  def change
    add_column :ticket_purchases, :price, :decimal, precision:  8, scale: 2, default: 0.00
  end
end
