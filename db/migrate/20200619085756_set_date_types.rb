class SetDateTypes < ActiveRecord::Migration[5.2]
  def change
    change_column :passes, :validity, :date
    change_column :special_offers, :validity, :date
    change_column :competitions, :validity, :date
  end
end
