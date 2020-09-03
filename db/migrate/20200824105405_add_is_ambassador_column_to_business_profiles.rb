class AddIsAmbassadorColumnToBusinessProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :business_profiles, :is_ambassador, :boolean, default: false
  end
end
