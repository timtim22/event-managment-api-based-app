class AddReaderIdToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :reader_id, Integer
  end
end
