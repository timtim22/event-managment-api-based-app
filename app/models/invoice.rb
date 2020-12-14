class Invoice < ApplicationRecord
  belongs_to :user

  def total_amount
    "%.2f" % self[:total_amount] if self[:total_amount]
  end

  def amount
    "%.2f" % self[:amount] if self[:amount]
  end


def vat_amount
  "%.2f" % self[:vat_amount] if self[:vat_amount]
end
end
