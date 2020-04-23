class AddOneMoreColumnToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :validity_time, :datetime
  end
end
