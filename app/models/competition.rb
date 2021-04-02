class Competition < ApplicationRecord
  belongs_to :user, optional: true
  mount_uploader :image, ImageUploader
  mount_base64_uploader :image, ImageUploader
  has_many :registrations,->{ where(event_type: 'Competition') }, foreign_key: :event_id, class_name: "Registration", dependent: :destroy
  has_many :participants, through: :registrations, source: :user
  has_many :competition_winners
  has_many :views, dependent: :destroy, as: :resource
  has_many :viewers, through: :views, source: :user
  has_many :activity_logs, dependent: :destroy, as: :resource
  has_many :wallets, dependent: :destroy, as: :offer
  has_many :notifications, dependent: :destroy, as: :resource
  has_many :offer_shares, dependent: :destroy, as: :offer
  has_many :offer_forwardings, dependent: :destroy, as: :offer
  # validates :title, presence: true
  # validates :start_date, presence: true
  # validates :end_date, presence: true

  # validates :description, presence: true
 

  scope :upcoming, -> { where(['draw_time > ?', DateTime.now]) }
  scope :expired, -> { where(['draw_time < ?', DateTime.now]) }
  scope :sort_by_date, -> { order(draw_time: 'ASC') }

  #will automatically format price but db key and fuc name should be same
def price
  "%.2f" % self[:price] if self[:price]
end

end
