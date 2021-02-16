class RemovePlaceHolderFromEvent < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :placeholder
    remove_column :child_events, :placeholder
  end
end
