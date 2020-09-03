class AddDefaultFieldToDeviceTokenOnUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:users, :device_token, from: nil, to: '')
  end
end
