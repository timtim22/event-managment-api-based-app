class ChangeDefaultValueForPasses < ActiveRecord::Migration[5.2]
  def change
 	change_column_default :passes, :pass_type, 'guest_pass' 
  end
end
