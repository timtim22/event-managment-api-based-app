class SocialMedium < ApplicationRecord
  belongs_to :user, optional: true
end
