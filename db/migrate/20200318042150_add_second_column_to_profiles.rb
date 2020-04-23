class AddSecondColumnToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :age, :integer
  end
end
