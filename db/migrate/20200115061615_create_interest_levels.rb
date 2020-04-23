class CreateInterestLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :interest_levels do |t|
      t.integer :user_id
      t.integer :event_id
      t.string :level, default: '0'

      t.timestamps
    end
  end
end
