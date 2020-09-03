class AddDefaultValuesToNullableFieldsOnEvents < ActiveRecord::Migration[5.2]
  def change
    
    change_column_default :events, :name, from: nil, to: ''
    change_column_default :events, :start_date, from: nil, to: ''
    change_column_default :events, :start_time, from: nil, to: ''
    change_column_default :events, :host, from: nil, to: ''
    change_column_default :events, :description, from: nil, to: ''
    change_column_default :events, :created_at, from: nil, to: ''
    change_column_default :events, :updated_at, from: nil, to: ''
    change_column_default :events, :location, from: nil, to: ''
    change_column_default :events, :event_type, from: nil, to: 'public'
    change_column_default :events, :end_date, from: nil, to: ''
    change_column_default :events, :price_type, from: nil, to: 'free'
    change_column_default :events, :lat, from: nil, to: ''
    change_column_default :events, :lng, from: nil, to: ''

  end
end
