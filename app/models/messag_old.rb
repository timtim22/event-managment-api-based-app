class Message < ApplicationRecord
    belongs_to :user
    has_many :replies, dependent: :destroy
    scope :get_messages, -> (user_id,recipient_id) { where(:user_id => user_id).where(:recipient_id => recipient_id) }
end
