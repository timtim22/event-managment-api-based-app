class ChangeSchemaOfSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :special_offers, :lat, :string
    add_column :special_offers, :lng, :string
    remove_column :special_offers, :user_id
  end
end
