class AddProfileNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :profile_name, :string, default: ''
    
  end
end
