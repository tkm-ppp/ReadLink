class ChangeUserLibraries < ActiveRecord::Migration[7.2]
  def change
    # ここで既存のテーブルにカラムを追加するなどの処理を行います。
    add_column :user_libraries, :new_column_name, :string unless column_exists?(:user_libraries, :user_id)
  end
end
