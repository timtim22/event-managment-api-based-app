class AddSnapChatToBusinessProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :business_profiles, :snapchat, :string, default: ''
  end
end
