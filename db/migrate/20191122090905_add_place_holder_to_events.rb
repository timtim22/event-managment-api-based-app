class AddPlaceHolderToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :placeholder, :string, :default => 'http://placehold.it/900x300'
  end
end
