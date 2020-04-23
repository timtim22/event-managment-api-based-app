class AddOneMoreColumnToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :ranking, :integer, default: 1
  end
end
