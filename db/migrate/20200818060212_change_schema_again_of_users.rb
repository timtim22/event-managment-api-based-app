class ChangeSchemaAgainOfUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :image_link
    remove_column :users, :is_subscribed
    remove_column :users, :eventbrite_token
    remove_column :users, :follow_request_status
    add_column    :users, :web_user, :boolean,  default: false
  end
end
