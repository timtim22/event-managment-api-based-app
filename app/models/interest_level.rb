class InterestLevel < ApplicationRecord
  belongs_to :user, optional: true
  has_many :notifications, dependent: :destroy, as: :resource
 # belongs_to :event
  belongs_to :child_event
end