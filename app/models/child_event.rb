class ChildEvent < ApplicationRecord
 belongs_to :event
 belongs_to :user
 scope :not_expired, -> { where(['end_date > ?', DateTime.now]) }
 scope :sort_by_date, -> { order(start_date: 'ASC') }
 mount_uploader :image, ImageUploader
 mount_base64_uploader :image, ImageUploader

 has_many :comments, dependent: :destroy, foreign_key: :event_id
 has_many :users, through: :comments
 has_many :interest_levels, dependent: :destroy, foreign_key: :event_id
 has_many :interest_levels, dependent: :destroy, foreign_key: :event_id
 has_many :interested_interest_levels, ->{ where(level: 'interested') }, foreign_key: :event_id, class_name: 'InterestLevel', dependent: :destroy, foreign_key: :event_id
 has_many :interested_users, through: :interested_interest_levels, source: :user
 has_many :going_interest_levels, -> { where(level: 'going') }, foreign_key: :event_id, class_name: 'InterestLevel', dependent: :destroy, foreign_key: :event_id
 has_many :going_users, through: :going_interest_levels, source: :user
 has_many :views, dependent: :destroy, as: :resource, foreign_key: :event_id
 has_many :viewers, through: :views, source: :user, foreign_key: :event_id
 has_many :event_shares, dependent: :destroy, foreign_key: :event_id
 has_many :event_forwardings, dependent: :destroy, foreign_key: :event_id
end