class SetDefaultForSocalInProfiles < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:profiles, :facebook, from: nil, to: 'Not connected')
    change_column_default(:profiles, :twitter, from: nil, to: 'Not connected')
    change_column_default(:profiles, :youtube, from: nil, to: 'Not connected')
    change_column_default(:profiles, :linkedin, from: nil, to: 'Not connected')
    change_column_default(:profiles, :instagram, from: nil, to: 'Not connected')
  end
end
