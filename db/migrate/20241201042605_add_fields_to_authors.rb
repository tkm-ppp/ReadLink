class AddFieldsToAuthors < ActiveRecord::Migration[7.0]
  def change
    change_table :authors do |t|
      t.references :book, foreign_key: true  # bookとのリレーションを追加
      t.boolean :is_representative, null: false  # 代表著者かどうかのフラグ
    end
  end
end
