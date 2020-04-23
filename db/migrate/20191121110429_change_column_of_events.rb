class ChangeColumnOfEvents < ActiveRecord::Migration[5.2]
  def change
  	change_column :events, :feature_media_link, :string, :default => ''
  	change_column :events, :additional_media, :string, :default => ''
 end
end
