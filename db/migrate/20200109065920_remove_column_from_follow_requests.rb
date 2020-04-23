class RemoveColumnFromFollowRequests < ActiveRecord::Migration[5.2]
  def change
    remove_column :follow_requests, :follow_id
  end
end
