class ChangeNewColumnNameToUserIdInUserLibraries < ActiveRecord::Migration[7.2]
  def change
    rename_column :user_libraries, :new_column_name, :user_id
  end
end
