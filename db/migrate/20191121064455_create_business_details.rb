class CreateBusinessDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :business_details do |t|
      t.string :name
      t.string :type
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
