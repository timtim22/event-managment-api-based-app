class AddIsSubscribeColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_subscribed, :boolean, default: false
  end
end
