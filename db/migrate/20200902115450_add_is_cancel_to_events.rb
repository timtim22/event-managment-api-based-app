class AddIsCancelToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :is_cancelled, :boolean, default: false
  end
end
