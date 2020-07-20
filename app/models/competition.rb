class Competition < ApplicationRecord
  belongs_to :user, optional: true
  mount_uploader :image, ImageUploader
  has_many :registrations,->{ where(event_type: 'Competition') }, foreign_key: :event_id, class_name: "Registration", dependent: :destroy
  has_many :participants, through: :registrations, source: :user

  validates :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true 
  validates :start_time, presence: true
  validates :end_time, presence: true 
  validates :validity_time, presence: true 
  validates :description, presence: true 
  validates :location, presence: true
  validates :validity, presence: true

  scope :not_expired, -> { where(['validity > ?', DateTime.now]) }
end
