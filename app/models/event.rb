class Event < ApplicationRecord
validates :name, presence: true
validates :image, presence: true
validates :start_date, presence: true
validates :end_date, presence: true 
validates :start_time, presence: true
validates :end_time, presence: true 
validates :description, presence: true 
validates :location, presence: true
validate  :has_one_category_at_least
validates :terms_conditions, presence: true

belongs_to :user, optional: true
has_many :comments, dependent: :destroy
has_many :users, through: :comments
has_many :categorizations, dependent: :destroy
has_many :categories, through: :categorizations
has_many :interest_levels, dependent: :destroy
has_many :interested_interest_levels, ->{ where(level: 'interested') }, foreign_key: :event_id, class_name: 'InterestLevel', dependent: :destroy
has_many :interested_users, through: :interested_interest_levels, source: :user
has_many :going_interest_levels, -> { where(level: 'going') }, foreign_key: :event_id, class_name: 'InterestLevel', dependent: :destroy
has_many :going_users, through: :going_interest_levels, source: :user
has_many :event_attachments, dependent: :destroy
has_many :passes, dependent: :destroy
has_many :registrations, dependent: :destroy
has_many :reminders, dependent: :destroy
has_one :ticket, dependent: :destroy # remove later
has_many :tickets, dependent: :destroy #in case of ticket type
has_many :views, dependent: :destroy, as: :resource
has_many :viewers, through: :views, source: :user
has_many :sponsors, dependent: :destroy
has_many :event_shares, dependent: :destroy
has_many :event_forwardings, dependent: :destroy
has_many :activity_logs, dependent: :destroy, as: :resource

accepts_nested_attributes_for :event_attachments


mount_uploader :image, ImageUploader
mount_base64_uploader :image, ImageUploader


mount_base64_uploader :image, ImageUploader
paginates_per 20
#custom queries/scopes\
scope :events_by_date, ->(date) { Event.where(:date => date) }
scope :expired, -> { where(['end_date < ?', DateTime.now]) }
scope :not_expired, -> { where(['end_date > ?', DateTime.now]) }
scope :sort_by_date, -> { order(start_date: 'ASC') }

def has_one_category_at_least
  if categories.empty?
    errors.add(:categories, "should be chosen at least one.")
  end
end

#will automatically format price but db key and fuc name should be same
def price
  "%.2f" % self[:price] if self[:price]
end

def start_price
  "%.2f" % self[:start_price] if self[:start_price]
end

def end_price
  "%.2f" % self[:end_price] if self[:end_price]
end





end
