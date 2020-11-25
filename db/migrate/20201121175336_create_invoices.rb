class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.integer :user_id
      t.decimal :amount, :precision => 8, :scale => 2, default: 0.00
      t.decimal :total_amount, :precision => 8, :scale => 2, default: 0.00
      t.string  :tax_invoice_number
      t.integer :total_tickets
      t.decimal :vat_amount, :precision => 8, :scale => 2, default: 0.00
      t.integer :event_id
      t.timestamps
    end
  end
end
