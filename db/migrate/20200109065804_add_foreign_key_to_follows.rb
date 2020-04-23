class AddForeignKeyToFollows < ActiveRecord::Migration[5.2]
  def change
    add_column :follows, :follow_request_id, :integer
  end
end
