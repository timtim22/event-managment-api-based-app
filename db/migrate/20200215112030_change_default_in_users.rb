class ChangeDefaultInUsers < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:users, :lat, from: nil, to: '')
    change_column_default(:users, :lng, from: nil, to: '')
  end
end
