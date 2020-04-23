class CreateLocationRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :location_requests do |t|
      t.integer :user_id
      t.integer :askee_id

      t.timestamps
    end
  end
end
