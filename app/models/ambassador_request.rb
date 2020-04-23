class AmbassadorRequest < ApplicationRecord
  belongs_to :user
  belongs_to :business, foreign_key: :business_id, class_name: 'User'
end
