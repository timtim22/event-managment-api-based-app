class SetColumnDefaultsOnPasses < ActiveRecord::Migration[5.2]
  def change
    change_column_default :passes, :title, from: nil, to: ''
    change_column_default :passes, :description, from: nil, to: ''
    change_column_default :passes, :validity, from: nil, to: ''
    change_column_default :passes, :created_at, from: nil, to: ''
    change_column_default :passes, :updated_at, from: nil, to: ''
    change_column_default :passes, :validity_time, from: nil, to: ''
    change_column_default :passes, :valid_from, from: nil, to: ''
    change_column_default :passes, :valid_to, from: nil, to: ''
  end
end
