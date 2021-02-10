class AddFirstCatIdColumnToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :first_cat_id, Integer
  end
end
