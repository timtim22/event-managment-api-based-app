class CreateFollowRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :follow_requests do |t|
      t.integer :sender_id
      t.string :sender_name
      t.string :sender_avatar
      t.integer :recipient_id
      t.boolean :status, default: false
      t.timestamps
    end
  end
end
