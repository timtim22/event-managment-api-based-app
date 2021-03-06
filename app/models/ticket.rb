class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :event
  
  
 
  has_many :wallets, dependent: :destroy, as: :offer
  has_many :ticket_purchases, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :refund_requests, dependent: :destroy
  has_many :redemptions, dependent: :destroy, as: :offer
  has_many :going_interest_levels, -> { where(level: 'going') }, foreign_key: :ticket_id, class_name: 'InterestLevel', dependent: :destroy
  has_many :reservations, dependent: :destroy
  


 
  # validates :title, presence: true
  # validates :quantity, presence: true
  # validates :per_head, presence: true
  def price
    "%.2f" % self[:price] if self[:price]
  end
  
  def start_price
    "%.2f" % self[:start_price] if self[:start_price]
  end
  
  def end_price
    "%.2f" % self[:end_price] if self[:end_price]
  end
 
end
