class CreateSpecialOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :special_offers do |t|
      t.integer :user_id
      t.string :title, default: ''
      t.string :sub_title, default: ''
      t.string :redeem_code, default: ''
      t.string :image, default: ''
      t.datetime :date
      t.datetime :time
      t.datetime :end_time
      t.datetime :validity
      t.text :description, default: ''
      t.string :location, default: ''
      t.string :lat, default: ''
      t.string :lng, default: ''
      t.integer :ambassador_rate, default: 1
      t.text :terms_conditions, default: ''
      t.boolean :agreed_to_terms, default: false
      t.timestamps
    end
  end
end
