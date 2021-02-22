class HostAndPlaceholderFromCompetition < ActiveRecord::Migration[5.2]
  def change
  	remove_column :competitions, :host
  	remove_column :competitions, :placeholder
  end
end
