class Category < ApplicationRecord
  has_many :categorizations
  has_many :events, through: :categorizations

  validates :name, presence: true
  #validates :color_code, presence: true
  #validates :icon, presence: true


  mount_uploader :icon, ImageUploader
end
