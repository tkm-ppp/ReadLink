class AddSystemidToLibraries < ActiveRecord::Migration[7.2]
  def change
    create_table :user_libraries, id: false do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :library, null: false, foreign_key: true
  end
end
