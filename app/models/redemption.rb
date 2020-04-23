class Redemption < ApplicationRecord
  belongs_to :offer, polymorphic: true
  belongs_to :user
end
