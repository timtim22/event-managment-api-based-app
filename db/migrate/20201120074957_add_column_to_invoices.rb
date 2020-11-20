class AddColumnToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :total_tickets, :integer
    add_column :invoices, :vat_amount, :integer
    add_column :invoices, :event_id, :integer
  end
end
