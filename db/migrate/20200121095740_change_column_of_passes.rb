class ChangeColumnOfPasses < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:passes, :terms_conditions, from: '0', to: '')
  end
end
