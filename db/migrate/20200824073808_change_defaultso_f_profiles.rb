class ChangeDefaultsoFProfiles < ActiveRecord::Migration[5.2]
  def change
    change_column_default :profiles, :facebook, from: "Not connected", to: ''
    change_column_default :profiles, :twitter, from: "Not connected", to: ''
    change_column_default :profiles, :snapchat, from: "Not connected", to: ''
    change_column_default :profiles, :instagram, from: "Not connected", to: ''
    change_column_default :profiles, :youtube, from: "Not connected", to: ''
  end
end
