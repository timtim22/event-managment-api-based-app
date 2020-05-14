class Transaction < ApplicationRecord
  belongs_to :payee, foreign_key: :payee_id, class_name: 'User'
  belongs_to :ticket
  belongs_to :user
end
