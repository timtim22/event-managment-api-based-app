class CreateBusinessProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :business_profiles do |t|
      t.integer :user_id
      t.string :profile_name, default: ''
      t.string :contact_name, default: ''
      t.string :address, default: ''
      t.string :website, default: ''
      t.text   :about, default: ''
      t.string :vat_number, default: ''
      t.string :charity_number, default: ''
      t.string :twitter, default: ''
      t.string :facebook, default: ''
      t.string :linkedin, default: ''
      t.string :instagram, default: ''
      t.string :snapchat, default: ''
      t.string :youtube, default: ''
      t.boolean :is_ambassador, default: false
      t.boolean :is_charity, default: false
      t.string :location, default: ''
      t.string :lat, default: ''
      t.string :lng, default: ''
      t.timestamps
    end
  end
end
