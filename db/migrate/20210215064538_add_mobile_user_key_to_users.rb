class AddMobileUserKeyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :mobile_user, :boolean, default: true
  end
end
