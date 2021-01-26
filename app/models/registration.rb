class Registration < ApplicationRecord
  belongs_to :user
  belongs_to :event, polymorphic: true
  has_many :notifications, dependent: :destroy, as: :resource
end
