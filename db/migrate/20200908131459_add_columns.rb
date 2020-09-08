class AddColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :validity, :datetime
    add_column :special_offers, :validity, :datetime
    add_column :competitions, :validity, :datetime
  end
end
