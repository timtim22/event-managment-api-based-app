class AddPassToChildEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :child_events, :pass, :string, :default => "false"
  end
end
