class Sponsor < ApplicationRecord
  belongs_to :event, optional: true
  mount_uploader :sponsor_image, ImageUploader
end
