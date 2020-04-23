class ChatChannel < ApplicationRecord
  belongs_to :user
  
  scope :check_for_mutual_channel, -> (sender, recipient) { ChatChannel.where(user_id: sender.id).where(recipient_id: recipient.id)
.or(ChatChannel.where(user_id: recipient.id).where(recipient_id: sender.id)) }

end
