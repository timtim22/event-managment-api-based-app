class FriendRequest < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'
  has_many :activity_logs, dependent: :destroy, as: :resource
end
