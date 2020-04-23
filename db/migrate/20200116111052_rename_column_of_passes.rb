class RenameColumnOfPasses < ActiveRecord::Migration[5.2]
  def change
    rename_column :passes, :name, :title
  end
end
