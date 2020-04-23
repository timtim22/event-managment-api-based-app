class ChangeUpdateColumnsOfPasses < ActiveRecord::Migration[5.2]
  def change
    rename_column  :redemptions, :pass_id, :offer_id
    add_column :redemptions, :offer_type, :string
  end
end
