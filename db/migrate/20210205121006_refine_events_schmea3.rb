class RefineEventsSchmea3 < ActiveRecord::Migration[5.2]
  def change
    remove_column :child_events, :is_private
    remove_column :child_events, :feature_media_link
    remove_column :events, :feature_media_link
  end
  end
end
