class SetColumnDefaultsOnCompetitions < ActiveRecord::Migration[5.2]
  def change
    change_column_default :competitions, :title, from: nil, to: ''
    change_column_default :competitions, :description, from: nil, to: ''
    change_column_default :competitions, :image, from: nil, to: ''
    change_column_default :competitions, :created_at, from: nil, to: ''
    change_column_default :competitions, :updated_at, from: nil, to: ''
    change_column_default :competitions, :end_date, from: nil, to: ''
    change_column_default :competitions, :start_time, from: nil, to: ''
    change_column_default :competitions, :end_time, from: nil, to: ''
    change_column_default :competitions, :location, from: nil, to: ''
    change_column_default :competitions, :lat, from: nil, to: ''
    change_column_default :competitions, :lng, from: nil, to: ''
    change_column_default :competitions, :price, from: nil, to: ''
    change_column_default :competitions, :host, from: nil, to: ''
    change_column_default :competitions, :validity_time, from: nil, to: ''
  end
end
