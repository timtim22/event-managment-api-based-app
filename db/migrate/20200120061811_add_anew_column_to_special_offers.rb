class AddAnewColumnToSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :special_offers, :user_id, :integer
  end
end
