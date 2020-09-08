class FixDateTypeIssue < ActiveRecord::Migration[5.2]
  def up
    rename_column :events, :start_time, :start_time_old
    rename_column :events, :end_time, :end_time_old
    rename_column :special_offers, :end_time, :end_time_old
    rename_column :passes, :validity, :validity_old
    rename_column :special_offers, :validity, :validity_old
    rename_column :competitions, :validity, :validity_old
    rename_column :tickets, :start_price, :start_price_old
    rename_column :tickets, :end_price, :end_price_old

    add_column :events, :start_time, :datetime
    add_column :events, :end_time, :datetime
    add_column :special_offers, :end_time, :datetime
    add_column :passes, :validity, :datetime
    add_column :special_offers, :validity, :datetime
    add_column :competitions, :validity, :datetime
    add_column :tickets, :start_price, :float
    add_column :tickets, :end_price, :float
   
    remove_column :events, :start_time_old
    remove_column :events, :end_time_old
    remove_column :special_offers, :end_time_old
    remove_column :passes, :validity_old
    remove_column :special_offers, :validity_old
    remove_column :competitions, :validity_old
    remove_column :tickets, :start_price_old
    remove_column :tickets, :end_price_old
  end
end
