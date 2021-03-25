class RemoveFieldsFromNewUserModel < ActiveRecord::Migration[5.2]
  def change
  	add_column :business_profiles, :description, :string, default: ""
  	remove_column :users, :description
  end
end
