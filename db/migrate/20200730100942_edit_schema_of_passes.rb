class EditSchemaOfPasses < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :valid_from, :datetime
    add_column :passes, :valid_to, :datetime
    rename_column :passes, :number_of_passes, :quantity
  end
end
