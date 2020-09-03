class SetColumnDefaultsOnTickets < ActiveRecord::Migration[5.2]
  def change
    change_column_default :tickets, :ticket_type, from: nil, to: 'paid'
    change_column_default :tickets, :price, from: nil, to: 0
    change_column_default :tickets, :quantity, from: nil, to: 1
    change_column_default :tickets, :title, from: nil, to: ''
  end
end
