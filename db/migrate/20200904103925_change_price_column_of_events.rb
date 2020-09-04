class ChangePriceColumnOfEvents < ActiveRecord::Migration[5.2]
  def change
    change_column :events, :price, :float, default: 0.0
  end
end
