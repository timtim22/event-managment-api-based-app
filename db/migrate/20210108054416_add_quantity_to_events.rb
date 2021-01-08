class AddQuantityToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :quantity, :integer
  end
end
