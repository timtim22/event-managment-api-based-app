class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :comment, presence: true

  scope :unread, -> { where(read_at: nil )}

  
end
