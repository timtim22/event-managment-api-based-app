class AddIsOnlineToProfile < ActiveRecord::Migration[5.2]
  def change
	add_column :profiles, :is_online, :boolean, default: false
  end
end
