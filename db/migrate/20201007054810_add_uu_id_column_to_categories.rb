class AddUuIdColumnToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :uuid, :string
  end
end
