class AddTwoFieldsToPasses < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :terms_conditions, :text, default: '0'
    add_column :passes, :agreed_to_terms, :boolean, default: false
  end
end
