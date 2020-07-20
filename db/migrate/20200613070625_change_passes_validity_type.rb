class ChangePassesValidityType < ActiveRecord::Migration[5.2]
  def change
    change_column :passes, :validity, :date
  end
end
