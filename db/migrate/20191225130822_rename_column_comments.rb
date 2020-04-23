class RenameColumnComments < ActiveRecord::Migration[5.2]
  def change
    rename_column :comments, :message, :comment
  end
end
