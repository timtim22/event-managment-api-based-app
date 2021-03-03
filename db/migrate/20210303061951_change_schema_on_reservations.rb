class ChangeSchemaOnReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :reservations, :reserved_for_id, :integer 
    remove_column :reservations, :quantity
  end
end
