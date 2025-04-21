class CreateUserLibraries < ActiveRecord::Migration[7.2]
  def change
    create_table :user_libraries do |t|
      t.bigint :user_id, null: false
      t.bigint :library_id, null: false

      t.timestamps
    end
    add_index :user_libraries, :user_id
    add_index :user_libraries, :library_id
    add_foreign_key :user_libraries, :users
    add_foreign_key :user_libraries, :libraries
  end
end
