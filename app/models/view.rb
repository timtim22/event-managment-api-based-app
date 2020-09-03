class View < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :user, optional: true
end
