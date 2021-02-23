class ChildEvent < ApplicationRecord
 belongs_to :event
 belongs_to :user
 scope :not_expired, -> { where("start_time > ?",  DateTime.now) }
 scope :sort_by_date, -> { order(start_time: 'ASC') }
 scope :active, -> { where(status: "active") }
 mount_uploader :image, ImageUploader
 mount_base64_uploader :image, ImageUploader
 validates :image, file_size: { less_than: 3.megabytes }

 has_many :comments, dependent: :destroy
 has_many :replies, dependent: :destroy
 has_many :activity_logs, dependent: :destroy, as: :resource
 has_many :users, through: :comments
 has_many :interest_levels, dependent: :destroy, foreign_key: :child_event_id, table_name: "InterestLevel"
 has_many :interested_interest_levels, ->{ where(level: 'interested') }, foreign_key: :child_event_id, class_name: 'InterestLevel', dependent: :destroy
 has_many :interested_users, through: :interested_interest_levels, source: :user
 has_many :going_interest_levels, -> { where(level: 'going') }, foreign_key: :child_event_id, class_name: 'InterestLevel', dependent: :destroy
 has_many :going_users, through: :going_interest_levels, source: :user
 has_many :views, dependent: :destroy, as: :resource
 has_many :viewers, through: :views, source: :user
 has_many :event_shares, dependent: :destroy
 has_many :event_forwardings, dependent: :destroy
 has_many :reminders, dependent: :destroy
 has_many :notifications, dependent: :destroy, as: :resource

end
