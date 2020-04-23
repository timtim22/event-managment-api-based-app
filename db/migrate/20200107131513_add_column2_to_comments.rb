class AddColumn2ToComments < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :user_avatar, :string
  end
end
