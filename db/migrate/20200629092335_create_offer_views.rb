class CreateOfferViews < ActiveRecord::Migration[5.2]
  def change
    create_table :offer_views do |t|
      t.integer :offer_id
      t.integer :user_id

      t.timestamps
    end
  end
end
