class RemoveAddressFromBusinessProfile < ActiveRecord::Migration[5.2]
  def change
    remove_column :business_profiles, :address, :json
  end
end
