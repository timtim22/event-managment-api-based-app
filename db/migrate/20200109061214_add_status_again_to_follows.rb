class AddStatusAgainToFollows < ActiveRecord::Migration[5.2]
  def change
    add_column :follows, :status, :boolean, default: false
  end
end
