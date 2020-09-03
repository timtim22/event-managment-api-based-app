class RemoveMoreColumnFromProfiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :profiles, :stripe_account, :string
    remove_column :profiles, :location, :string
  end
end
