class Profile < ApplicationRecord
  belongs_to :user

  def earning
    "%.2f" % self[:earning] if self[:earning]
  end
  
end
