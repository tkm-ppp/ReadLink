class UpdateBooksTable < ActiveRecord::Migration[7.0]
  def change
    # isbnカラムを追加
    add_column :books, :isbn, :string

    # google_books_api_idカラムを削除
    remove_column :books, :google_books_api_id

    # genreカラムを削除
    remove_column :books, :genre
  end
end