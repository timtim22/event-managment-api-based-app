class ChangeColumnTypeOnUsers < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :is_email_verified, :boolean, default: false
    change_column :users, :web_user, :boolean, default: false
    remove_column :users, :contact_name
  end
end
