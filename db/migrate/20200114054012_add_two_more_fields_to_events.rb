class AddTwoMoreFieldsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :creator_name, :string
    add_column :events, :creator_image, :string
  end
end
