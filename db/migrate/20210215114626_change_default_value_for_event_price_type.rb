class ChangeDefaultValueForEventPriceType < ActiveRecord::Migration[5.2]
  def change
  	change_column :events, :price_type, :string, default: ""
  	change_column :child_events, :price_type, :string, default: ""
  end
end
