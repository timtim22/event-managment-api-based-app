class EventView < ApplicationRecord
  belongs_to :event, optional: true
  belongs_to :user, optional: true
end
