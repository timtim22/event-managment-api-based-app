class AdminRequest < ApplicationRecord
  belongs_to :user
  belongs_to :admin, class_name: 'User'
  has_many :activity_logs, dependent: :destroy, as: :resource
  has_many :notifications, dependent: :destroy, as: :resource
end
