class CreateReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :replies do |t|
      t.string :message
      t.string :from
      t.datetime :read_at
      t.references :message, foreign_key: true

      t.timestamps
    end
  end
end
