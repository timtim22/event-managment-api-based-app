class Reply < ApplicationRecord
  belongs_to :comment
  belongs_to :user

  validates :msg, presence: true
end
