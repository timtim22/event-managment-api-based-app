class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.integer :user_id
      t.integer :amount
      t.integer :total_amount
      t.string :tax_invoice_number
      t.timestamps
    end
  end
end
