class RemoveColumnsFromProfiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :profiles, :dob, :string
    remove_column :profiles, :mobile, :string
  end
end
