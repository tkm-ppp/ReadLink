class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.references :user, foreign_key: true
      t.string :title
      t.text :info_link
      t.string :systemid
      t.string :publisher
      t.string :published_date
      t.string :image_link
      t.integer :page_count
      t.decimal :rating, precision: 2, scale: 1
      t.string :genre
      t.text :description
      t.timestamps
    end
  end
end
