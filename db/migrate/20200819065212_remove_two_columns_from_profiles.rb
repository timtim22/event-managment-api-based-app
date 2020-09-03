class RemoveTwoColumnsFromProfiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :profiles, :age
    remove_column :profiles, :image_link
  end
end
