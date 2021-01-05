class ChildEvent < ApplicationRecord
 belongs_to :event
 belongs_to :user
 scope :not_expired, -> { where(['end_date > ?', DateTime.now]) }
 scope :sort_by_date, -> { order(start_date: 'ASC') }
 mount_uploader :image, ImageUploader
 mount_base64_uploader :image, ImageUploader

end
