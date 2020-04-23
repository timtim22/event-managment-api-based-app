class AddImageColumnToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :eventbrite_image, :string, default: ''
  end
end
