class Reminder < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true,
  belongs_to :child_event, optional: true,
end
