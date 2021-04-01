class AddPhoneDetailsInUser < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :phone_details, :string, default: ""
  end
end
