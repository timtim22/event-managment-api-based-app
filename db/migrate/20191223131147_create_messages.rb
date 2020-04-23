class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.integer :recipient_id
      t.text :message
      t.datetime :read_at
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
