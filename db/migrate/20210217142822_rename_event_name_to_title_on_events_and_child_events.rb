class RenameEventNameToTitleOnEventsAndChildEvents < ActiveRecord::Migration[5.2]
  def change
    rename_column :events, :name, :title
    rename_column :child_events, :name, :title
  end
end
