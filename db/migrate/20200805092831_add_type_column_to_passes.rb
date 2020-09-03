class AddTypeColumnToPasses < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :pass_type, :string, default: 'ordinary'
  end
end
