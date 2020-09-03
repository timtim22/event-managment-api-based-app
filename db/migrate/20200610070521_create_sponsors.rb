class CreateSponsors < ActiveRecord::Migration[5.2]
  def change
    create_table :sponsors do |t|
      t.integer :event_id
      t.string :name
      t.string :sponsor_image
      t.timestamps
    end
  end
end
