class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :event

  has_many :replies, dependent: :destroy

  validates :comment, presence: true

  scope :unread, -> { where(read_at: nil )}

  
end
