class EventForwarding < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :user, optional: true
  has_many :notifications, dependent: :destroy, as: :resource

end
