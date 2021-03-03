class Reservation < ApplicationRecord
   belongs_to :reserved_for, foreign_key: :reserved_for_id, class_name: "User"
   belongs_to :user
   belongs_to :ticket
end
