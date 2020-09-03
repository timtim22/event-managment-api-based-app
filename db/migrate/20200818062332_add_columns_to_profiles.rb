class AddColumnsToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :first_name, :string, default: ''
    add_column :profiles, :last_name, :string, default: ''
    add_column :profiles, :device_token, :string, default: ''
    add_column :profiles, :dob, :datetime, default: ''
    add_column :profiles, :gender, :string, default: ''
    add_column :profiles, :location, :string, default: ''
    add_column :profiles, :lat, :string, default: ''
    add_column :profiles, :lng, :string, default: ''
    add_column :profiles, :earning, :integer, default: 0
    add_column :profiles, :is_subscribed, :boolean, default: false
    add_column :profiles, :is_ambassador, :boolean, default: false
    add_column :profiles, :image_link, :string, default: ''
  end
end
