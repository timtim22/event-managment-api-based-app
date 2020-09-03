class AddYouTubeToBusinessProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :business_profiles, :youtube, :string, default: ''
  end
end
