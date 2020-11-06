class Redemption < ApplicationRecord
  belongs_to :offer, polymorphic: true
  belongs_to :user
  scope :sort_by_date, -> { order(created_at: 'ASC') }
end
