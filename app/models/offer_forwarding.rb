class OfferForwarding < ApplicationRecord
  belongs_to :user
  belongs_to :offer, polymorphic: true
end
