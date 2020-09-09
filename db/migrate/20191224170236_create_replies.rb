class CreateReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :replies do |t|
      t.string :msg
      t.integer :user_id
      t.integer :comment_id
      t.datetime :read_at
      t.timestamps
    end
  end
end
