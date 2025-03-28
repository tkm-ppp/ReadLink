class CreateAlreadyReadBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :already_read_books do |t|
      t.references :user, null: false, foreign_key: true
      t.string :isbn, null: false

      t.timestamps
    end
    add_index :already_read_books, [:user_id, :isbn], unique: true # 重複登録を防ぐためのインデックス
  end
end
