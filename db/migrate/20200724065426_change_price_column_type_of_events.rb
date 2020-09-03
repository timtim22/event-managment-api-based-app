class ChangePriceColumnTypeOfEvents < ActiveRecord::Migration[5.2]
  def change
    change_column :events, :price, :integer, default: 0
  end
end
