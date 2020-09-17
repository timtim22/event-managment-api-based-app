class AddPriceRangeColumnToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :price_range, :boolean, default: false
  end
end
