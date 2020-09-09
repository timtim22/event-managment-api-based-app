class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.string :first_name, default: ''
      t.string :last_name, default: ''
      t.string :device_token, default: ''
      t.datetime :dob
      t.string :phone_number, default: ''
      t.text :about, default: ''
      t.string :gender, default: ''
      t.string :location, default: ''
      t.string :lat, default: ''
      t.string :lng, default: ''
      t.boolean :is_email_subscribed, default: false
      t.decimal :earning, :precision => 8, :scale => 2, default: 0.00
      t.boolean :is_ambassador, default: false
      t.integer :ranking, default: 0
      t.boolean :add_social_media_links, defautl: false
      t.string :facebook, default: ''
      t.string :twitter, default: ''
      t.string :snapchat, default:''
      t.string :instagram, default: ''
      t.string :linkedin, default: ''
      t.string :youtube, default: ''
  
      t.timestamps
    end
  end
end
