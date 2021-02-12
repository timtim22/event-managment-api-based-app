class AddPerheadColumnToPasses < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :per_head, :integer
  end
end
