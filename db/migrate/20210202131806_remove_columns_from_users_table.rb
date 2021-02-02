class RemoveColumnsFromUsersTable < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :dob
    remove_column :users, :gender
    remove_column :users, :is_email_verified
    remove_column :profiles, :is_email_subscribed

    remove_column :users, :phone_verified
    remove_column :users, :verification_code
    remove_column :users, :facebook
    remove_column :users, :linkedin
    remove_column :users, :twitter
    remove_column :users, :snapchat
    remove_column :users, :youtube
    remove_column :users, :instagram
    
  end
end
