class AddMoreColumnsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :price, :string
    add_column :events, :lat, :string
    add_column :events, :lng, :string
  end
end
