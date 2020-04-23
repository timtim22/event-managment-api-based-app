class AddPriceDefaultEvents < ActiveRecord::Migration[5.2]
  def up
  def change

    change_column :events, :price, :integer, default: 0
  end
end

def down
  def change

    change_column :events, :price, :string, default: 0
  end
end
end
