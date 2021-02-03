class RemoveAppUserAndWebUserFromUsers < ActiveRecord::Migration[5.2]
  def change
  	remove_column :users, :app_user, :boolean
  	remove_column :users, :web_user, :boolean
  end
end
