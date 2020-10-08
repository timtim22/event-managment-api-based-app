class AddPassColumnToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :pass, :string, default: 'false'
  end
end
