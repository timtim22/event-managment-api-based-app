class RenameIsSubscribeColumnOfProfiles < ActiveRecord::Migration[5.2]
  def change
    rename_column :profiles, :is_subscribed, :is_email_subscribed
  end
end
