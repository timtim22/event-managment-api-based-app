class OfferShare < ApplicationRecord
  belongs_to :user
  belongs_to :offer, polymorphic: true
  has_many :notifications, dependent: :destroy, as: :resource
  has_many :activity_logs, dependent: :destroy, as: :resource
  belongs_to :business, foreign_key: "business_id", class_name: "User"

end
