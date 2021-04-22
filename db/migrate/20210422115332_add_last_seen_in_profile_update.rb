class AddLastSeenInProfileUpdate < ActiveRecord::Migration[5.2]
  def change
	remove_column :profiles, :last_seen
	add_column :profiles, :last_seen, :datetime
  end
end
