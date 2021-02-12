class SchemaUpdaterForQrCode < ActiveRecord::Migration[5.2]
  def change
    remove_column :tickets, :redeem_code
    add_column    :events, :redeem_code, :string, default: ''
  end
end
