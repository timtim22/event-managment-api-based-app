class AddFollowRequestStatusColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :follow_request_status, :boolean
  end
end
