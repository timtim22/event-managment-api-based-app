class InterestLevel < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event, foreign_key: :event_id, class_name: "ChildEvent"
