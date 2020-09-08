class ChangeSchemaOfRegistrations < ActiveRecord::Migration[5.2]
  def change
    change_column :registrations, :user_id, :integer
    change_column :registrations, :event_id, :integer
  end
end
