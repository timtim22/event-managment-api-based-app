class AddIsPrivateColumnToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :is_private, :boolean, default: false
  end
end
