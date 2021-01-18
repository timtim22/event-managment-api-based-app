class EventShare < ApplicationRecord
  belongs_to :child_event
  belongs_to :user, optional: true
  has_many :notifications, dependent: :destroy, as: :resource

end
