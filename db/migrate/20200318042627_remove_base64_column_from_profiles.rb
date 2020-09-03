class RemoveBase64ColumnFromProfiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :profiles, :base64_string
  end
end
