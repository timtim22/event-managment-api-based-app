class EventShare < ApplicationRecord
  belongs_to :event, foreign_key: :event_id
  belongs_to :child_event_id
  belongs_to :user, optional: true
  has_many :notifications, dependent: :destroy, as: :resource

end
