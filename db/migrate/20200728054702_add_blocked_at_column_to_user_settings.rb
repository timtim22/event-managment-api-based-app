class AddBlockedAtColumnToUserSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :user_settings, :blocked_at, :datetime
  end
end
