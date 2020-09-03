class CompetitionWinner < ApplicationRecord
  belongs_to :user, optional: true
end
