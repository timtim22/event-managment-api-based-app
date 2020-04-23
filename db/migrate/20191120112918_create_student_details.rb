class CreateStudentDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :student_details do |t|
      t.string :university
      t.string :email
      t.string :student_id
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
