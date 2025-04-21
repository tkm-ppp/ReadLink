class CreateAlreadyReadBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :already_read_books do |t|
      t.bigint :user_id, null: false
      t.string :isbn, null: false

      t.timestamps
    end
    add_index :already_read_books, [:user_id, :isbn], unique: true
    add_index :already_read_books, :user_id
    add_foreign_key :already_read_books, :users
  end
end