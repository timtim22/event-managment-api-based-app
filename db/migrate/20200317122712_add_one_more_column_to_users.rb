class AddOneMoreColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :earning, :integer, default: 0
  end
end
