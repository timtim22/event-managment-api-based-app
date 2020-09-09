class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :verification_code, default: ''
      t.string :avatar, default: 'avatar.png'
      t.string :phone_number,default: ''
      t.boolean :app_user, default: false
      t.boolean :phone_verified, default: false
      t.string :stripe_state, default: ''
      t.string :connected_account_id, default: ''
      t.string :is_email_verified, default: false
      t.string :web_user, default: false
      t.string :password_digest
      t.timestamps
    end
  end
end
