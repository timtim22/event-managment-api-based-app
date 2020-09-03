class AddIsCharityToBusinessProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :business_profiles, :is_charity, :boolean, default: false
  end
end
