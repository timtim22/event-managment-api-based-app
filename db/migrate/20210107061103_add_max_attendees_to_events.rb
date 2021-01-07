class AddMaxAttendeesToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :max_attendees, :integer, default: 1
  end
end
