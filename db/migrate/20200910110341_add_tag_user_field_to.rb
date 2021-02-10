class AddTagUserFieldTo < ActiveRecord::Migration[5.2]
  def change
    add_column :replies, :reply_to_id, Integer
  end
end
