class AddColumnToPasses < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :user_id, :integer
  end
end
