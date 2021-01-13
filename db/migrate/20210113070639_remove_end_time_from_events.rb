class RemoveEndTimeFromEvents < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :end_time
  end
end
