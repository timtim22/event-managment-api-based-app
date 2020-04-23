class AddOnMoreColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :eventbrite_token, :string
  end
end
