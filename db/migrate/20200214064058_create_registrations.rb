class CreateRegistrations < ActiveRecord::Migration[5.2]
  def change
    create_table :registrations do |t|
      t.string :user_id
      t.string :event_id
      t.string :event_type

      t.timestamps
    end
  end
end
