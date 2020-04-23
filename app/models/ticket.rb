class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :event
 
  has_many :wallets, dependent: :destroy, as: :offer
  has_many :ticket_purchases, dependent: :destroy

  validates :title, presence: true
  validates :price, presence: true
  validates :quantity, presence: true
  validates :per_head, presence: true
end
