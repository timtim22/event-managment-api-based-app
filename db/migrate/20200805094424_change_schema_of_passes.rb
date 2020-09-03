class ChangeSchemaOfPasses < ActiveRecord::Migration[5.2]
  def change
    remove_column :passes, :type
  end
end
