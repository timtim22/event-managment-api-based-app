class RemoveProfileNameAndContactNameFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :profile_name
    remove_column :users, :contact_name
  end
end
