class AddReaderIdToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :reader_id, :integer
  end
end
