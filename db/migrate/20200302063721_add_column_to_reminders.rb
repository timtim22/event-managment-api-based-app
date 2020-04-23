class AddColumnToReminders < ActiveRecord::Migration[5.2]
  def change
    add_column :reminders, :level, :string
  end
end
