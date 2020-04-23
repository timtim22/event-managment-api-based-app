class ChangeSchemaAgainOfSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :special_offers, :user_id, :integer
    remove_column :special_offers, :event_id
  end
end
