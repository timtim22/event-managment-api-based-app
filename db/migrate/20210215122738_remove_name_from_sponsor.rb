class RemoveNameFromSponsor < ActiveRecord::Migration[5.2]
  def change
  	remove_column :sponsors, :name
  end
end
