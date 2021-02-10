class AddFollowForeignKeyToFollowRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :follow_requests, :follow_id, Integer
  end
end
