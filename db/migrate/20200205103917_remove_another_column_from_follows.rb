class RemoveAnotherColumnFromFollows < ActiveRecord::Migration[5.2]
  def change
    remove_column :follows, :follow_request_id, :string
  end
end
