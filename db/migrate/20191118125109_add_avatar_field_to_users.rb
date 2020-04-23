class AddAvatarFieldToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :avatar, :string, :default => 'avatar.png'
  end
end
