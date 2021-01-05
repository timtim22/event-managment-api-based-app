class EventShare < ApplicationRecord
  belongs_to :event, foreign_key: :event_id, class_name: "ChildEvent"
  belongs_to :user, optional: true
  has_many :notifications, dependent: :destroy, as: :resource

end
