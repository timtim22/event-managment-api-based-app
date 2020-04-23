class AddOneMoreColumToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :placeholder, :string, default: 'http://placehold.it/900x300'
  end
end
