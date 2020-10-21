class Wallet < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :offer, polymorphic: true
 
end
