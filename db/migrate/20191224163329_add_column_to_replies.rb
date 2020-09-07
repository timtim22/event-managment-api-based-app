class AddColumnToReplies < ActiveRecord::Migration[5.2]
  def change
    add_column :replies, :from, :string
  end
end
