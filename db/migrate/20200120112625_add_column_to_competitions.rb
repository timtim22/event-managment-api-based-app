class AddColumnToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :host, :string
  end
end
