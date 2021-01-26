class Wallet < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :offer, polymorphic: true
  has_many :notifications, dependent: :destroy, as: :resource

  scope :sort_by_date, -> { order(validity: 'DESC') }
end
