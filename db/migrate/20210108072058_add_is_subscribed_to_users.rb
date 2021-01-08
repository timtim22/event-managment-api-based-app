class AddIsSubscribedToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_subscribed, :boolean
  end
end
