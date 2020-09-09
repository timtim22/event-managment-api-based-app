class CreatePasses < ActiveRecord::Migration[5.2]
  def change
    create_table :passes do |t|
      t.integer :event_id
      t.integer :user_id
      t.string :title, default: ''
      t.text :description, default: ''
      t.datetime :validity
      t.datetime :validity_time
      t.string :redeem_code, default: ''
      t.text :terms_conditions, default: ''
      t.boolean :agreed_to_terms, default: false
      t.integer :ambassador_rate, default: 1
      t.integer :quantity, default: 1
      t.datetime :valid_from
      t.datetime :valid_to
      t.string :pass_type, default: 'ordinary'
      t.integer :redeem_code, default: 0
      t.timestamps
    end
  end
end
