class AddColumnsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :is_repetive, :boolean, default: false
    add_column :events, :frequency, :string, default: 'daily'
  end
end
