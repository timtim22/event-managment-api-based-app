class DropUsersRelevantTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :business_details
    drop_table :student_details
  end
end
