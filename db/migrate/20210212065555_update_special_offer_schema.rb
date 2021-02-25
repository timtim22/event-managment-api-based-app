class UpdateSpecialOfferSchema < ActiveRecord::Migration[5.2]
  def change
    remove_column :special_offers, :qr_code
    add_column :special_offers, :qr_code, :string, default: ""
  end
end
