class CreateActivityLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_logs do |t|
      t.integer :user_id
      t.string :browser
      t.string :ip_address
      t.string :controller
      t.string :action
      t.string :note
      t.string :params
      t.timestamps
    end
  end
end
