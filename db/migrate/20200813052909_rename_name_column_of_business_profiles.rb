class RenameNameColumnOfBusinessProfiles < ActiveRecord::Migration[5.2]
  def change
    rename_column :business_profiles, :name, :profile_name
  end
end
