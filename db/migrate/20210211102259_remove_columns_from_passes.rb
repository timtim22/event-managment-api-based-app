class RemoveColumnsFromPasses < ActiveRecord::Migration[5.2]
  def change
    remove_column :passes, :validity_time
    remove_column :passes, :qr_code
    remove_column :passes, :terms_conditions
    remove_column :passes, :agreed_to_terms
    remove_column :passes, :valid_from
    remove_column :passes, :valid_to
  end
end
