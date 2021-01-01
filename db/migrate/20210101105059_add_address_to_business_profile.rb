class AddAddressToBusinessProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :business_profiles, :address, :jsonb
  end
end
