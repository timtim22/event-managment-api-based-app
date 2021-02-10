class AddFirstCatIdToChildEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :child_events, :first_cat_id, Integer
  end
end
