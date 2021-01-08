class AddQuantityToChildEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :child_events, :quantity, :integer
  end
end
