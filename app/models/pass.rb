class Pass < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :user, optional: true #Pass creator 

  has_many :redemptions, dependent: :destroy, as: :offer
  has_many :offer_forwardings, dependent: :destroy, as: :offer
  has_many :offer_shares, dependent: :destroy, as: :offer
  
  has_many :wallets, dependent: :destroy, as: :offer
  has_many :owners, through: :wallets, source: :user # who added it to wallet

  validates :title, presence: true
  validates :description, presence: true
  validates :validity, presence: true
  # validates :redeem_code, presence: true, length: {maximum: 3}, numericality: {only_integer: true}

  scope :not_expired, -> { where(['validity > ?', DateTime.now]) }
end
