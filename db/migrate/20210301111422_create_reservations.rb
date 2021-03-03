class CreateReservations < ActiveRecord::Migration[5.2]
  def change
    create_table :reservations do |t|
      t.integer :user_id
      t.integer :ticket_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :quantity, default: 0
      t.timestamps
    end
  end
end
