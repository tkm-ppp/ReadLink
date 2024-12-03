class AddFieldsToBooks < ActiveRecord::Migration[7.0]
  def change
    remove_column :books, :systemid
    add_column :books, :google_books_api_id, :string, null: false

    add_index :books, :google_books_api_id, unique: true  # 重複を許さないインデックスを追加
  end
end
