class ChangeSchemaOfReplies < ActiveRecord::Migration[5.2]
  def change
     remove_column :replies, :from
     change_column :replies, :msg, :message
     add_column :replies, :user_id, :integer
  end
end
