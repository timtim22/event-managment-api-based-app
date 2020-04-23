class AddMoreColumnToPasses < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :is_redeemed, :boolean, default: false
  end
end
