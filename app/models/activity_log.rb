class ActivityLog < ApplicationRecord
  belongs_to :user
  belongs_to :resource, polymorphic: true
  scope :sort_by_date, -> { order(created_at: 'ASC') }
end
