class OfferForwarding < ApplicationRecord
  belongs_to :user
  belongs_to :offer, polymorphic: true
  belongs_to :recipient, foreign_key: :recipient_id, class_name: 'User'
  has_many :activity_logs, dependent: :destroy, as: :resource
  has_many :notifications, dependent: :destroy, as: :resource

end
