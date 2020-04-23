class ChangeColumnDefaultOfPasses < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:passes, :ambassador_name, from: '0', to: '')
  end
end
