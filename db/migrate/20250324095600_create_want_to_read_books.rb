class CreateWantToReadBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :want_to_read_books do |t|
      t.references :user, null: false, foreign_key: true
      t.string :isbn, null: false

      t.timestamps
    end
    add_index :want_to_read_books, [:user_id, :isbn], unique: true # 重複登録を防ぐためのインデックス
  end
end
