class ChangeEventColumnType < ActiveRecord::Migration[5.2]
  def change
  	change_column :events, :date, :string
  	change_column :events, :time, :string
  end
end
