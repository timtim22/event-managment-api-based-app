class AddAmbasaddarToPasses < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :ambassador_name, :string, default: '0'
  end
end
