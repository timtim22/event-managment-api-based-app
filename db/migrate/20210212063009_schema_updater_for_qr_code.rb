class SchemaUpdaterForQrCode < ActiveRecord::Migration[5.2]
  def change
    remove_column :tickets, :qr_code
    add_column    :events, :qr_code, :string, default: ''
  end
end
