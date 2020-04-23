class AddOneMoreColumnToPasses < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :validity_time, :datetime, default: ''
  end
end
