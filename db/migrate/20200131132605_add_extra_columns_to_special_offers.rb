class AddExtraColumnsToSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :special_offers, :sub_title, :string
    add_column :special_offers, :image, :string
    add_column :special_offers, :location, :string
    add_column :special_offers, :date, :datetime
    add_column :special_offers, :validity_time, :datetime
  end
end
