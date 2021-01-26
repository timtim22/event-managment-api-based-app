class InterestLevel < ApplicationRecord
  belongs_to :user, optional: true
 # belongs_to :event
  belongs_to :child_event
  belongs_to :ticket, optional: true
end