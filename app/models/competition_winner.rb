class CompetitionWinner < ApplicationRecord
  belongs_to :competition
  belongs_to :user, optional: true


end
