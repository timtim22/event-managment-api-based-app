class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :name
      t.timestamp :date
      t.timestamp :time
      t.string :external_link
      t.string :host
      t.text :description
      t.string :feature_media_link
      t.string :additional_media
      t.timestamps
    end
  end
end
