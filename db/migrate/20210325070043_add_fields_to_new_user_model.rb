class AddFieldsToNewUserModel < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :description, :string, default: ""
  	add_column :social_media, :spotify, :string, default: ""
  end
end
