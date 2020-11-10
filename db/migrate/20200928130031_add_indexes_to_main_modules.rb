class AddIndexesToMainModules < ActiveRecord::Migration[5.2]
  def change
    add_index :events, :user_id
    add_index :passes, :user_id
    add_index :passes, :event_id
    add_index :competitions, :user_id
    add_index :tickets, :user_id
    add_index :tickets, :event_id
  end
end
