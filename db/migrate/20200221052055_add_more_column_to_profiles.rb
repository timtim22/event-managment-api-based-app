class AddMoreColumnToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :linkedin, :string, default: ''
    add_column :profiles, :youtube, :string, default: ''
  end
end
