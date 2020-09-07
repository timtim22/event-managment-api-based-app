class ChangeColumnInReplies < ActiveRecord::Migration[5.2]
  def change
    rename_column :replies, :message, :msg
  end
end
