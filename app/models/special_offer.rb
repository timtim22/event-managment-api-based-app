class SpecialOffer < ApplicationRecord

  belongs_to :user, optional: true
  has_one :redemption, dependent: :destroy, as: :offer
  has_many :wallets, dependent: :destroy, as: :offer
  validates :title, presence: true
  validates :description, presence: true
  validates :validity, presence: true
  mount_uploader :image, ImageUploader
end
