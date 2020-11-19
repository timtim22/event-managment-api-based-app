class Notification < ApplicationRecord
  belongs_to :actor, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :notifiable, polymorphic: true
  belongs_to :resource, polymorphic: true

  has_one :location_share, dependent: :destroy
  has_one :location_request, dependent: :destroy

  scope :unread, ->{ where(read_at: nil) }
  scope :recent, ->{ order(created_at: :desc).limit(5) }
end
