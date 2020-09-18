class VipPassShare < ApplicationRecord
  belongs_to :user
  belongs_to :pass
end
