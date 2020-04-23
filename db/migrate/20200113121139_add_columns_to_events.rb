class AddColumnsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :event_type, :string, defautl: 'mygo'
    rename_column :events, :date, :start_date
    add_column :events, :end_date, :datetime
    add_column :events, :price_type, :string
  end
end
