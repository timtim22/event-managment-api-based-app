class AddActionTypeToActivityLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :activity_logs, :action_type, :string, :defaul => ''
  end
end
