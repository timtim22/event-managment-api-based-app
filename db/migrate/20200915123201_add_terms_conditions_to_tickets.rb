class AddTermsConditionsToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :terms_conditions, :text, default: ''
  end
end
