class ChangeStartTimeColumnOnSpecialOffer < ActiveRecord::Migration[5.2]
  def change
    rename_column :special_offers, :validity_time, :end_time
  end
end
