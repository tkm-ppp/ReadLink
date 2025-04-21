class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :name, null: false
      t.string :username
      t.text :library_ids
      t.string :provider
      t.string :uid
    end
    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
  end
end
