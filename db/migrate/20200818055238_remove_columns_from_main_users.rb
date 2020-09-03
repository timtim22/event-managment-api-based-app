class RemoveColumnsFromMainUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :device_token
    remove_column :users, :dob
    remove_column :users, :dob
    remove_column :users, :gender
    remove_column :users, :location
    remove_column :users, :lat
    remove_column :users, :lng
    remove_column :users, :earning
    remove_column :users, :is_ambassador
  end
end
