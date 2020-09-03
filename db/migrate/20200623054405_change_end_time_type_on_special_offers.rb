class ChangeEndTimeTypeOnSpecialOffers < ActiveRecord::Migration[5.2]
  def up

    change_column :special_offers, :end_time, :string
  end

  def down
    change_column :special_offers, :end_time, :date
  end
end
