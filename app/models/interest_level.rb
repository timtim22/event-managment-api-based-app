class InterestLevel < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event, optional: true
  belongs_to :child_event, optional: true
end
