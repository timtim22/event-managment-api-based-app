class AddOneNewColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_ambassador, :boolean, default: false
  end
end
