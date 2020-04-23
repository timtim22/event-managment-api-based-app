class AddDefaultsToProfiles < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:profiles, :about, from: nil, to: '')
    change_column_default(:profiles, :stripe_account, from: nil, to: false)
    change_column_default(:profiles, :add_social_media_links, from: nil, to: false)
    change_column_default(:profiles, :facebook, from: nil, to: '')
    change_column_default(:profiles, :twitter, from: nil, to: '')
    change_column_default(:profiles, :snapchat, from: nil, to: '')
    change_column_default(:profiles, :instagram, from: nil, to: '')
    change_column_default(:profiles, :location, from: nil, to: '')
  end
end
