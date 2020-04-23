class AddTwoColumnsToActivityLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_logs, :resource_title, :string
    add_column :activity_logs, :method, :string
    add_column :activity_logs, :url, :string
  end
end
