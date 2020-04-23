class CreateCompetitions < ActiveRecord::Migration[5.2]
  def change
    create_table :competitions do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.string :image
      t.timestamp :start_date
      t.timestamp :end_date
      t.timestamp :start_time
      t.timestamp :end_time
      t.string :location
      t.string :lat
      t.string :lng
      t.string :validity
      t.string :price
      t.timestamps
    end
  end
end
