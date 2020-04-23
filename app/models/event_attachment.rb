class EventAttachment < ApplicationRecord
  belongs_to :event, optional: true
  mount_uploader :media, MediaUploader
end
