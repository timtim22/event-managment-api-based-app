class AddBusinessIdToViews < ActiveRecord::Migration[5.2]
  def change
    add_column :views, :business_id, Integer
  end
end
