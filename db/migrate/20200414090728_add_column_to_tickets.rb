class AddColumnToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :per_head, :integer, default: 1
  end
end
