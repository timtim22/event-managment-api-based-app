class ChangeSpecialOffetKeyDefaults < ActiveRecord::Migration[5.2]
  def change
  	change_column_default :special_offers, :start_time, ""
  	change_column_default :special_offers, :end_time, ""
  end
end
