class AddLastSeenInProfile < ActiveRecord::Migration[5.2]
  def change
	add_column :profiles, :last_seen, :string, default: ""
  end
end
