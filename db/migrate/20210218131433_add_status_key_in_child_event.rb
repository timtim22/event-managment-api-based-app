class AddStatusKeyInChildEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :child_events, :status, :string, default: ""
  end
end
