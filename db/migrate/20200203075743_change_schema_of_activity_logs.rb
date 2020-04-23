class ChangeSchemaOfActivityLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_logs, :resource_id, :integer
    add_column :activity_logs, :resource_type, :string
    remove_column :activity_logs, :note
    remove_column :activity_logs, :controller 
  end
end
