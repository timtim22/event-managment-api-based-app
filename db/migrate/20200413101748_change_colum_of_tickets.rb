class ChangeColumOfTickets < ActiveRecord::Migration[5.2]
  def change
    rename_column :tickets, :type, :price_type
  end
end
