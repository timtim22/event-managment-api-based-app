class AddNameAndContactNameToBusinessProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :business_profiles, :name, :string
    add_column :business_profiles, :contact_name, :string
  end
end
