class AddRefundColumnToRefundRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :refund_requests, :stripe_refund_response, :json
  end
end
