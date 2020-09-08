class ChangeRemainingSchemaOfRemainingModules < ActiveRecord::Migration[5.2]
  def change
    change_column :passes, :validity, :datetime
    change_column :special_offers, :validity, :datetime
    change_column :competitions, :validity, :datetime
    change_column :tickets, :start_price, :float
    change_column :tickets, :end_price, :float
  end
end
