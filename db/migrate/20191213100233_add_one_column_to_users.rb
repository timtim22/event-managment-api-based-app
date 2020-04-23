class AddOneColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :app_user, :boolean
  end
end
