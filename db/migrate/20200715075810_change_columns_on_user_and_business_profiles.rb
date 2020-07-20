class ChangeColumnsOnUserAndBusinessProfiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :business_profiles, :contact_name
    add_column :users, :contact_name, :string
  end
end
