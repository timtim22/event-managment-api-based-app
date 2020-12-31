class ChildEvent < ApplicationRecord
 belongs_to :event
 scope :not_expired, -> { where(['end_date > ?', DateTime.now]) }
 scope :sort_by_date, -> { order(start_date: 'ASC') }
end
