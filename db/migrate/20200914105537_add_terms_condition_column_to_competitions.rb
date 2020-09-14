class AddTermsConditionColumnToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :terms_conditions, :text, default: ''
  end
end
