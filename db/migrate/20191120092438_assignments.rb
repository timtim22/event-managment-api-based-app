class Assignments < ActiveRecord::Migration[5.2]
  def change
    create_table :assignments do |t|
    t.references :user
    t.references :role
  end
  end
end
