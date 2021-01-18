class View < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :user, optional: true
  # belongs_to :event, foreign_key: :event_id
  belongs_to :child_event, optional: true
  belongs_to :business, foreign_key: "business_id", class_name: "User"
end
