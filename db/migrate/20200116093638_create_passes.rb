class CreatePasses < ActiveRecord::Migration[5.2]
  def change
    create_table :passes do |t|
      t.string :name
      t.text :description
      t.string :validity, default: '0'
      t.integer :event_id
      t.integer :redeem_code, default: 0
      t.timestamps
    end
  end
end
