class RemoveColumnFromProfiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :profiles, :gender, :string
  end
end
