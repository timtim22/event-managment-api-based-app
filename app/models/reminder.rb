class Reminder < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  belongs_to :child_event, optional: true
  has_many :notifications, dependent: :destroy, as: :resource
end
