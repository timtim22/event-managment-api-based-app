class AddStatusColumnToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :status, :string, default: 'active'
  end
end
