class AddIsEmailVerifiedColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_email_verified, :boolean, default: false
  end
end
