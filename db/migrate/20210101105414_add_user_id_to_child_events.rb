class AddUserIdToChildEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :child_events, :user_id, :integer
  end
end
