class AddStatusToSpecialOffer < ActiveRecord::Migration[5.2]
  def change
  	add_column :special_offers, :status, :string, default: ""
  end
end
