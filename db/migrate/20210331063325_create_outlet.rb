class CreateOutlet < ActiveRecord::Migration[5.2]
  def change
    create_table :outlets do |t|
      t.references :special_offer, foreign_key: true
      t.string :outlet_address

      t.timestamps
    end
  end
end
