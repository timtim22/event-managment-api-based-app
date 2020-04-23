class RemoveColumnFromEvents < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :creator_name
    remove_column :events, :creator_image
  end
end
