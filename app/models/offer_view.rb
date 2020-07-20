class OfferView < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :offer, foreign_key: :offer_id, class_name: 'SpecialOffer'
end
