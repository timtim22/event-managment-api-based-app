class RenameCommentColumnOfReplies < ActiveRecord::Migration[5.2]
  def change
    rename_column :replies, :comment, :msg
  end
end
