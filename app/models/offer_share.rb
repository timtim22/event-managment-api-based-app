class OfferShare < ApplicationRecord
  belongs_to :user
  belongs_to :offer, polymorphic: true
  has_many :notifications, dependent: :destroy, as: :resource

end
