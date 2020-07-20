class SpecialOffer < ApplicationRecord

  belongs_to :user, optional: true
  has_many :redemptions, dependent: :destroy, as: :offer
  has_many :wallets, dependent: :destroy, as: :offer
  has_many :owners, through: :wallets, source: :user # who added it to wallet
  has_many :offer_views, foreign_key: :offer_id, dependent: :destroy
  has_many :offer_shares, dependent: :destroy, as: :offer

  validates :title, presence: true
  validates :description, presence: true
  validates :validity, presence: true
  mount_uploader :image, ImageUploader

  scope :not_expired, -> { where(['validity > ?', DateTime.now]) }
end
