class ChangeSchemaOfSponsors < ActiveRecord::Migration[5.2]
  def change
    add_column :sponsors, :external_url, :string
  end
end
