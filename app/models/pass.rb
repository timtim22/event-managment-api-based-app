class Pass < ApplicationRecord
  belongs_to :event
  belongs_to :user

  has_many :redemptions, dependent: :destroy, as: :offer
  has_many :offer_forwardings, dependent: :destroy, as: :offer
  has_many :offer_shares, dependent: :destroy, as: :offer
  has_many :wallets, dependent: :destroy, as: :offer
  has_many :owners, through: :wallets, source: :user # who added it to wallet
  has_many :views, dependent: :destroy, as: :resource
  has_many :viewers, through: :views, source: :user
  has_many :vip_pass_shares, dependent: :destroy
  has_many :notifications, dependent: :destroy, as: :resource
  has_many :activity_logs, dependent: :destroy, as: :resource


  validates :title, presence: true
 # validates :description, presence: true
  # validates :qr_code, presence: true, length: {maximum: 3}, numericality: {only_integer: true}

  scope :upcoming, -> { where(['validity > ?', DateTime.now]) }
  scope :expired, -> { where(['validity < ?', DateTime.now]) }
  scope :sort_by_date, -> { order(validity: 'ASC') }
end
