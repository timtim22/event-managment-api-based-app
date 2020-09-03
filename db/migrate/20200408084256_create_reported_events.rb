class CreateReportedEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :reported_events do |t|
      t.integer :event_id
      t.integer :user_id
      t.text :reason
      t.timestamps
    end
  end
end
