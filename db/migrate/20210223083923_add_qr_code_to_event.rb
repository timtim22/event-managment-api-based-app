class AddQrCodeToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :qr_code, :string, default: ""
  end
end
