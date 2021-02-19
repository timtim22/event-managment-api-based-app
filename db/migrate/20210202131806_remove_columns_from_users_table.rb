class RemoveColumnsFromUsersTable < ActiveRecord::Migration[5.2]
  def change
    business_profile.connected_account_id:dob
    business_profile.connected_account_id:gender
    business_profile.connected_account_id:is_email_verified
    remove_column :profiles, :is_email_subscribed

    business_profile.connected_account_id:phone_verified
    business_profile.connected_account_id:verification_code
    business_profile.connected_account_id:facebook
    business_profile.connected_account_id:linkedin
    business_profile.connected_account_id:twitter
    business_profile.connected_account_id:snapchat
    business_profile.connected_account_id:youtube
    business_profile.connected_account_id:instagram
    
  end
end
