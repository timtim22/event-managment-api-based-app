class CreateTicketPurchases < ActiveRecord::Migration[5.2]
  def change
    create_table :ticket_purchases do |t|
      t.integer :user_id
      t.integer :ticket_id
      t.timestamps
    end
  end
end
