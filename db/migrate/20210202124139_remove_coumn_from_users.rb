class RemoveCoumnFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :location_enabled
  end
end
