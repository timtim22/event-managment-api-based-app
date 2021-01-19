class RemoveColumnFromViews < ActiveRecord::Migration[5.2]
  def change
    remove_column :views, :child_event_id
  end
end
