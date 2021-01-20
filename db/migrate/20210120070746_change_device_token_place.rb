class ChangeDeviceTokenPlace < ActiveRecord::Migration[5.2]
  def change
    remove_column :profiles, :device_token
    add_column :users, :device_token, :string, default: "no_token"
  end
end
