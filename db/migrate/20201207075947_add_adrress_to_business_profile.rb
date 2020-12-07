class AddAdrressToBusinessProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :business_profiles, :address, :json
  end
end
