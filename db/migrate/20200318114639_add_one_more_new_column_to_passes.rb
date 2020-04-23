class AddOneMoreNewColumnToPasses < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :ambassador_rate, :string, default: '1'
    add_column :passes, :number_of_passes, :integer, default: 1
  end
end
