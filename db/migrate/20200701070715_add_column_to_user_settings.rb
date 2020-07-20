class AddColumnToUserSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :user_settings, :resource_type, :string
  end
end
