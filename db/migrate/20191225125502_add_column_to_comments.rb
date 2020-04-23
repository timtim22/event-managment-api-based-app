class AddColumnToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :from, :string
  end
end
