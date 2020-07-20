class AddReadAtColumnToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :read_at, :datetime
  end
end
