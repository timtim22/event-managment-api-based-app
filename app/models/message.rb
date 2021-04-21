class Message < ApplicationRecord
  belongs_to :user
  belongs_to :recipient, foreign_key: :recipient_id, :class_name => "User"

    mount_uploader :image, ImageUploader
	mount_base64_uploader :image, ImageUploader
    
    scope :get_messages, -> (user_id,recipient_id) { where(:user_id => user_id).where(:recipient_id => recipient_id) }
    scope :chat_history, -> (sender, recipient) {  where(user_id: recipient.id).where(recipient_id: sender.id).order("id ASC").or(Message.where(user_id: sender.id).where(recipient_id: recipient.id).order("id ASC"))}

    scope :unread, -> { where(read_at: nil) }

    scope :ascending, -> { reorder(created_at: :desc) }

    scope :last_message, -> (sender, recipient) { where(user_id: sender.id).where(recipient_id: recipient.id).or(where(user_id: recipient.id).where(recipient_id: sender.id)).order(created_at: 'DESC').first }
end