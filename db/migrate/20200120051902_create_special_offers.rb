class CreateSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :special_offers do |t|
      t.string :title
      t.text :description
      t.string :validity
      t.string :event_id
      t.text :terms_conditions, default: '0'
      t.boolean :agreed_to_terms, default: false
      t.timestamps
    end
  end
end
