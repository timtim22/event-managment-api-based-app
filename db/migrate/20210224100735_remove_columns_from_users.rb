class RemoveColumnsFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :app_user
    remove_column :users, :web_user
  end
end
