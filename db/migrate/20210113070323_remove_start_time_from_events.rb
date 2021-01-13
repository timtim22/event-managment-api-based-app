class RemoveStartTimeFromEvents < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :start_time
  end
end
