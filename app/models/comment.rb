class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  belongs_to :child_event

  has_many :replies, dependent: :destroy
  validates :comment, presence: true
  scope :unread, -> { where(read_at: nil )}

  
end
