class AddColumnToBusinessProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :business_profiles, :connected_account_id, :string, default: ""
    add_column :business_profiles, :business_profile, :string, default: ""
  end
end
