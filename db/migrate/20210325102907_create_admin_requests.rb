class CreateAdminRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_requests do |t|
      t.string :status, default: ''
      t.integer :user_id
      t.integer :admin_id
    end
  end
end
