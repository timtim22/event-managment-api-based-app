class AddColumnToTicketPurchaes < ActiveRecord::Migration[5.2]
  def change
    add_column :ticket_purchases, :quantity, Integer
  end
end
