class CreateLibraries < ActiveRecord::Migration[7.2]
  def change
    create_table :libraries do |t|
      t.string :formal
      t.string :url_pc
      t.string :address
      t.string :tel
      t.string :post
      t.string :geocode
      t.string :libkey
      t.string :libid
      t.string :systemid
      t.string :city

      t.timestamps
    end
    add_index :libraries, :formal
    add_index :libraries, :libid, unique: true
  end
end
