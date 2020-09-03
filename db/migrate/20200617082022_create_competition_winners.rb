class CreateCompetitionWinners < ActiveRecord::Migration[5.2]
  def change
    create_table :competition_winners do |t|
      t.integer :user_id
      t.integer :competition_id

      t.timestamps
    end
  end
end
