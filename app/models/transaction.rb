class Transaction < ApplicationRecord
  belongs_to :payee, foreign_key: :payee_id, class_name: 'User', optional: true
  belongs_to :ticket, optional: true
  belongs_to :user, optional: true
end
