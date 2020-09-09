class CreateTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :tickets do |t| 
      t.integer :user_id
      t.integer :event_id
      t.string :title, default: ''
      t.string :ticket_type, default: 'buy'
      t.decimal :price, :precision => 8, :scale => 2, default: 0.00
      t.integer :quantity, default: 1
      t.integer :per_head, default: 1
      t.decimal :start_price, :precision => 8, :scale => 2, default: 0.00
      t.decimal :end_price, :precision => 8, :scale => 2, default: 0.00
      t.timestamps
    end
  end
end
