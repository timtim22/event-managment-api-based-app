class ChangeAgainSchemaOfReplies < ActiveRecord::Migration[5.2]
  def change
    rename_column :replies, :msg, :comment
    rename_column :replies, :message_id, :comment_id
  end
end
