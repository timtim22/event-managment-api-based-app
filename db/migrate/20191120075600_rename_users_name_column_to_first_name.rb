class RenameUsersNameColumnToFirstName < ActiveRecord::Migration[5.2]
  def change
    rename_column(:users, 'name','first_name')
    rename_column(:users, 'username','last_name')
  end
end
