class AddPriceColumnToTicketPurchases < ActiveRecord::Migration[5.2]
  def change
    add_column :ticket_purchases, :price, :string
  end
end
