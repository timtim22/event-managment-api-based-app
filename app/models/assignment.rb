class Assignment < ApplicationRecord
    belongs_to :user
    belongs_to :role, optional: true
end
