class ChildEvent < ApplicationRecord
 belongs_to :event
 belongs_to :user
 scope :sort_by_date, -> { order(start_date: 'ASC') }
 mount_uploader :image, ImageUploader
 mount_base64_uploader :image, ImageUploader

 has_many :comments, dependent: :destroy, foreign_key: :child_event_id, table_name: "Comment"
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
end
