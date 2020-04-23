class ModifyEventsTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :time, :start_time
    add_column :events, :end_time, :string
  end
end
