class AddUuidColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :uuid, :string, default: ""
  end
end
