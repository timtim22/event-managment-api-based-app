class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.string :dob
      t.string :mobile
      t.string :about
      t.string :gender
      t.boolean :stripe_account
      t.boolean :add_social_media_links
      t.string :facebook
      t.string :twitter
      t.string :snapchat
      t.string :instagram
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
