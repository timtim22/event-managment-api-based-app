class AddAvatarColumnToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :user_avatar, :string
  end
end
