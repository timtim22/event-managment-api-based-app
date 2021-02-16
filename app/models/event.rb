
class Event < ApplicationRecord
validates :name, presence: true, on: :create
validates :image, presence: true, on: :create
validates :venue, presence: true, on: :create
# validates :start_date, presence: true, on: :create
# validates :end_date, presence: true, on: :create

validates :description, presence: true, on: :create
validates :location, presence: true, on: :create
validate  :has_one_category_at_least, on: :create
validates :image, file_size: { less_than: 3.megabytes }

belongs_to :user
has_many :comments, dependent: :destroy
has_many :notifications, dependent: :destroy, as: :resource
has_many :users, through: :comments
has_many :categorizations, dependent: :destroy
has_many :categories, through: :categorizations
has_many :interest_levels, dependent: :destroy
has_many :interested_interest_levels, -> { where(level: 'interested') }, foreign_key: :event_id, class_name: 'InterestLevel', dependent: :destroy
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
has_many :child_events, dependent: :destroy

accepts_nested_attributes_for :event_attachments

mount_uploader :image, ImageUploader
mount_base64_uploader :image, ImageUploader

scope :drafts, -> {where('start_date=? OR price_type=? OR event_forwardings=?', "","","").left_joins(:sponsors).merge(Sponsor.where(id: nil)).left_joins(:event_attachments).merge(EventAttachment.where(id: nil)) }



paginates_per 20
#custom queries/scopes\
scope :events_by_date, ->(date) { Event.where(:date => date) }
scope :expired, -> { where(['end_date < ?', DateTime.now]) }
scope :not_expired, -> { where("start_date > ?",  DateTime.now) }
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
