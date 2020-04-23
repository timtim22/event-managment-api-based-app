class CreateTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :tickets do |t|
      t.integer :user_id
      t.integer :event_id
      t.string :type
      t.integer :price
      t.integer :quantity

      t.timestamps
    end
  end
end
