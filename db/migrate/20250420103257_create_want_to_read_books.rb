class CreateWantToReadBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :want_to_read_books do |t|
      t.bigint :user_id, null: false
      t.string :isbn, null: false

      t.timestamps
    end
    add_index :want_to_read_books, [:user_id, :isbn], unique: true
    add_index :want_to_read_books, :user_id
    add_foreign_key :want_to_read_books, :users
  end
end
