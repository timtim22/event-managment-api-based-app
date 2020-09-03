class AddOneNewColumnToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :title, :string
  end
end
