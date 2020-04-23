class ChangeColumnDefaultOfEvents < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:events, :price, from: nil, to: 0)
  end
end
