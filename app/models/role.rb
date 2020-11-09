class Role < ApplicationRecord
  has_many :assignments, dependent: :destroy
  has_one :user, through: :assignments
end