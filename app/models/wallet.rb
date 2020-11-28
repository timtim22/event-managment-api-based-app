class Wallet < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :offer, polymorphic: true

  scope :sort_by_date, -> { order(validity: 'DESC') }
end
