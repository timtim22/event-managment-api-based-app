class SpecialOffer < ApplicationRecord

  belongs_to :user, optional: true
  has_many :redemptions, dependent: :destroy, as: :offer
  has_many :wallets, dependent: :destroy, as: :offer
  has_many :owners, through: :wallets, source: :user # who added it to wallet
  has_many :views, dependent: :destroy, as: :resource
  has_many :viewers, through: :views, source: :user
  has_many :offer_shares, dependent: :destroy, as: :offer
  has_many :offer_forwardings, dependent: :destroy, as: :offer
  has_many :activity_logs, dependent: :destroy, as: :resource
  has_many :notifications, dependent: :destroy, as: :resource

  validates :title, presence: true
  validates :description, presence: true
  validates :validity, presence: true
  validates :ambassador_rate, presence: true
  validates :image, presence: true, on: :create
  validates :location, presence: true
  validates :terms_conditions, presence: false

  mount_uploader :image, ImageUploader
  mount_base64_uploader :image, ImageUploader

  scope :not_expired, -> { where(['validity > ?', DateTime.now]) }
  scope :expired, -> { where(['validity < ?', DateTime.now]) }



end
