class Event < ApplicationRecord
validates :name, presence: true
validates :start_date, presence: true
validates :end_date, presence: true 
validates :start_time, presence: true
validates :end_time, presence: true 
validates :description, presence: true 
validates :location, presence: true
validate  :has_one_category_at_least
belongs_to :user, optional: true
has_many :comments, dependent: :destroy
has_many :users, through: :comments
has_many :categorizations, dependent: :destroy
has_many :categories, through: :categorizations
has_many :interest_levels, dependent: :destroy
has_many :interested_interest_levels, ->{ where(level: 'interested') }, foreign_key: :event_id, class_name: 'InterestLevel', dependent: :destroy
has_many :interested_users, through: :interested_interest_levels, source: :user
has_many :going_interest_levels, ->{ where(level: 'going') }, foreign_key: :event_id, class_name: 'InterestLevel', dependent: :destroy
has_many :going_users, through: :going_interest_levels, source: :user
has_many :event_attachments, dependent: :destroy
has_many :passes, dependent: :destroy
has_many :registrations, dependent: :destroy
has_many :reminders, dependent: :destroy
has_one :event_setting, dependent: :destroy
has_one :ticket, dependent: :destroy

accepts_nested_attributes_for :event_attachments

mount_uploader :image, ImageUploader

mount_base64_uploader :image, ImageUploader
paginates_per 20
#custom queries/scopes
scope :events_by_date, ->(date) { Event.where(:date => date) } 

def has_one_category_at_least
  if categories.empty?
    errors.add(:categories, "should be chosen at least one.")
  end
end


end
