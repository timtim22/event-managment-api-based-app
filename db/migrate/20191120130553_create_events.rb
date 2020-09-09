class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.integer :user_id
      t.string :name, default: ''
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :start_time
      t.datetime :end_time
      t.text :description, default: ''
      t.string :host, default: ''
      t.string :location, default: ''
      t.string :lat, default: ''
      t.string :lng, default: ''
      t.boolean :over_18, default: true
      t.boolean :event_forwarding, default: false
      t.boolean :allow_chat, default: true
      t.boolean :allow_additional_media, default: true
      t.integer :invitees, default: 0
      t.string :image, default: ''
      t.string :placeholder, default: 'http://placehold.it/900x300'
      t.string :feature_media_link, default: ''
      t.string :event_type, default: 'public'
      t.string :price_type, default: 'free'
      t.decimal :price, :precision => 8, :scale => 2, default: 0.00
      t.decimal :start_price, :precision => 8, :scale => 2, default: 0.00
      t.decimal :end_price, :precision => 8, :scale => 2 , default: 0.00
      t.boolean :is_cancelled, default: false
      t.timestamps
    end
  end
end
