class CreateCompetitions < ActiveRecord::Migration[5.2]
  def change
    create_table :competitions do |t|
      t.integer :user_id
      t.string :title, default: ''
      t.text :description, default: ''
      t.string :image, default: ''
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :start_time
      t.datetime :end_time
      t.datetime :validity
      t.datetime :validity_time
      t.decimal :price, :precision => 8, :scale => 2, default: 0.00
      t.string :location, defautl: ''
      t.string :lat, default: ''
      t.string :lng, default: ''
      t.string :host, default: ''
      t.string :placeholder, default: 'http://placehold.it/900x300'
      t.timestamps
    end
  end
end
