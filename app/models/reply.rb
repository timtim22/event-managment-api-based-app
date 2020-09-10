class Reply < ApplicationRecord
  belongs_to :comment, optional: true
  belongs_to :user, optional: true

  belongs_to :reply_to_user, class_name: "User", foreign_key: :reply_to_id

  validates :msg, presence: true
end
