class RenameColumnOfTickets < ActiveRecord::Migration[5.2]
  def change
    rename_column :tickets, :price_type, :ticket_type
  end
end
