class NewEventSchemaChange < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :start_time
    remove_column :events, :end_time
    remove_column :events, :lat
    remove_column :events, :lng
    remove_column :events, :feature_media_link
    remove_column :events, :host
    remove_column :events, :invitees

    remove_column :child_events, :start_time
    remove_column :child_events, :end_time
    remove_column :child_events, :lat
    remove_column :child_events, :lng
    remove_column :child_events, :feature_media_link
    remove_column :child_events, :host
    remove_column :child_events, :invitees

    add_column :events, :venue, :string, default: ""
    add_column :child_events, :venue, :string, default: ""
 end
end