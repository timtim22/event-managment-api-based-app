class AddColorCodeFieldToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :color_code, :string
  end
end
