class ChangeOneMoreColumnOfPasses < ActiveRecord::Migration[5.2]
  def change
    change_column :passes, :redeem_code, :string
  end
end
