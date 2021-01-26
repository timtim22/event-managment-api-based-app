class AddColumnToInterestLevels < ActiveRecord::Migration[5.2]
  def change
    add_column :interest_levels, :ticket_id, :integer
  end
end
