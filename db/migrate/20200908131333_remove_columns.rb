class RemoveColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :passes, :validity
    remove_column :special_offers, :validity
    remove_column :competitions, :validity
  end
end
