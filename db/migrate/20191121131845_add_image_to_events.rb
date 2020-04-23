class AddImageToEvents < ActiveRecord::Migration[5.2]
  def change
  	add_column :events, :image, :string, :default => 'http://via.placeholder.com/640x360'
  end
end
