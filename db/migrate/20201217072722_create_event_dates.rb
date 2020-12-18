class CreateEventDates < ActiveRecord::Migration[5.2]
  def change
    create_table :event_dates do |t|
      t.integer :event_id
      t.datetime :date
      t.timestamps
    end
  end
end
