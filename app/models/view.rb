class View < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :user, optional: true
  belongs_to :business, foreign_key: "business_id", class_name: "User"
end
