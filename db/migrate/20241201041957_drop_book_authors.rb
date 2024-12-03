class DropBookAuthors < ActiveRecord::Migration[7.0]
  def up
    drop_table :book_authors
  end
end
