class NewsFeed < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, on: :create
  validates :description, presence: true, on: :create
  validates :image, presence: true, on: :create

  mount_uploader :image, ImageUploader
  mount_base64_uploader :image, ImageUploader
end
