class RefineUserSchema < ActiveRecord::Migration[5.2]
  def change
    # remove_column :users, :app_user
    # remove_column :users, :web_user
    remove_column :users, :stripe_state
    remove_column :users, :connected_account_id
    remove_column :profiles, :location
    remove_column :profiles, :lat
    remove_column :profiles, :lng
    remove_column :profiles, :earning
    remove_column :profiles, :is_ambassador
    remove_column :profiles, :ranking
    remove_column :profiles, :add_social_media_links
    remove_column :profiles, :facebook
    remove_column :profiles, :twitter
    remove_column :profiles, :snapchat
    remove_column :profiles, :linkedin
    remove_column :profiles, :youtube
    remove_column :profiles, :instagram
    remove_column :profiles, :about
    remove_column :business_profiles, :about
    remove_column :business_profiles, :lat
    remove_column :business_profiles, :lng
    remove_column :business_profiles, :is_ambassador
    remove_column :business_profiles, :facebook
    remove_column :business_profiles, :twitter
    remove_column :business_profiles, :snapchat
    remove_column :business_profiles, :address
    remove_column :business_profiles, :location
    remove_column :business_profiles, :linkedin
    remove_column :business_profiles, :youtube
    remove_column :business_profiles, :instagram
    add_column :business_profiles, :stripe_state, :string, default: "rendom_string"
    add_column :business_profiles, :connected_account_id, :string, default: ""
    add_column :users, :dob, :string, default: ""
    add_column :users, :gender, :string, default: ""
    add_column :users, :about, :string, default: ""
    add_column :users, :location, :string, default: ""
    add_column :users, :facebook, :string, default: ""
    add_column :users, :twitter, :string, default: ""
    add_column :users, :snapchat, :string, default: ""
    add_column :users, :linkedin, :string, default: ""
    add_column :users, :youtube, :string, default: ""
    add_column :users, :instagram, :string, default: ""
  end
end
