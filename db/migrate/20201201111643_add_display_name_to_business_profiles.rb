class AddDisplayNameToBusinessProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :business_profiles, :display_name, :string
  end
end
